# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataConversionTool::RestaurantImporter do
  subject(:importer) do
    described_class.new(
      created_records:,
      skipped_records:,
      logs:,
      errors:,
      skipped_keys:
    )
  end

  let(:created_records) { Hash.new(0) }
  let(:skipped_records) { Hash.new(0) }
  let(:logs) { [] }
  let(:errors) { [] }
  let(:skipped_keys) { [] }

  describe '#import' do
    context 'when the root key is missing' do
      let(:json) { { 'invalid_key' => [] } }

      before { importer.import(json) }

      it 'returns an empty array' do
        expect(errors).not_to be_empty
      end

      it 'includes a descriptive error message' do
        expect(errors.join).to include('Missing required root key')
      end
    end

    context 'when there is one valid restaurant without menus' do
      let(:json) { { 'restaurants' => [{ 'name' => 'Sushi Town' }] } }

      it 'creates a new restaurant' do
        expect do
          importer.import(json)
        end.to change(Restaurant, :count).by(1)
      end

      it 'increments created_records[:restaurants]' do
        importer.import(json)
        expect(created_records[:restaurants]).to eq(1)
      end

      it 'does not add errors' do
        importer.import(json)
        expect(errors).to be_empty
      end

      it 'logs restaurant creation' do
        importer.import(json)
        expect(logs.join).to include('SUCCESS')
      end
    end

    context 'when the restaurant has nested menus' do
      let(:json) do
        {
          'restaurants' => [
            {
              'name' => 'Burger Heaven',
              'menus' => [
                { 'name' => 'Lunch', 'items' => [] }
              ]
            }
          ]
        }
      end

      it 'delegates menu import to MenuImporter' do
        expect_any_instance_of(DataConversionTool::MenuImporter).to receive(:import)
          .with(data: { 'name' => 'Lunch', 'items' => [] })

        importer.import(json)
      end
    end

    context 'when restaurant creation fails due to validation' do
      let(:json) { { 'restaurants' => [{ 'name' => '' }] } }

      it 'does not create a restaurant' do
        expect do
          importer.import(json)
        end.not_to change(Restaurant, :count)
      end

      it 'increments skipped_records[:restaurants]' do
        importer.import(json)
        expect(skipped_records[:restaurants]).to eq(1)
      end

      it 'logs the failure' do
        importer.import(json)
        expect(errors.join).to include('Failed to create restaurant')
      end
    end

    context 'when an exception occurs during creation' do
      let(:json) { { 'restaurants' => [{ 'name' => 'Boom' }] } }

      before do
        allow(Restaurant).to receive(:new).and_raise(StandardError.new('Something exploded'))
      end

      it 'rescues the exception and logs the error' do
        importer.import(json)
        expect(errors.join).to include('Unexpected error creating restaurant')
        expect(errors.join).to include('Something exploded')
      end
    end
  end
end
