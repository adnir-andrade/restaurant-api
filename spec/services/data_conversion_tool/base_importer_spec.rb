# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataConversionTool::BaseImporter do
  subject(:importer) do
    Class.new(described_class) do
      def import(_json)
        # no operation, just a mock for testing
      end
    end.new(
      logs:,
      errors:,
      skipped_keys:,
      created_records:,
      skipped_records:
    )
  end

  let(:logs) { [] }
  let(:errors) { [] }
  let(:skipped_keys) { Set.new(['unknown_key']) }
  let(:created_records) { Hash.new(0) }
  let(:skipped_records) { Hash.new(0) }

  describe '#summarize_logs' do
    context 'when there are errors and skipped keys' do
      before do
        errors << 'Something went wrong'
        skipped_keys << 'unexpected_key'
        importer.summarize_logs
      end

      it 'adds a warning section to the logs' do
        expect(logs).to include(a_string_matching(/WARNINGS/i))
        expect(logs).to include('Something went wrong')
      end

      it 'adds an unknown keys section to the logs' do
        expect(logs).to include(a_string_matching(/Unknown keys/i))
        expect(logs).to include(/- unknown_key/)
        expect(logs).to include(/- unexpected_key/)
      end
    end

    context 'when there are no errors or skipped keys' do
      let(:skipped_keys) { Set.new }
      let(:errors) { [] }

      it 'does not modify the logs' do
        expect { importer.summarize_logs }.not_to(change { logs })
      end
    end
  end

  describe '.parse_json' do
    context 'with valid JSON file' do
      let(:file_path) { Rails.root.join('spec/fixtures/files/restaurant_data.json') }

      it 'returns a parsed hash' do
        parsed = described_class.parse_json(file_path)
        expect(parsed).to be_a(Hash)
        expect(parsed['restaurants']).to be_an(Array)
      end
    end

    context 'with invalid JSON file' do
      let(:file_path) { Rails.root.join('spec/fixtures/files/invalid.json') }

      before do
        File.write(file_path, '{ this is not valid JSON }')
      end

      after do
        FileUtils.rm(file_path)
      end

      it 'raises an error and logs it' do
        expect(Rails.logger).to receive(:error).with(/JSON parsing failed/)
        expect do
          described_class.parse_json(file_path)
        end.to raise_error('Invalid JSON file')
      end
    end
  end
end
