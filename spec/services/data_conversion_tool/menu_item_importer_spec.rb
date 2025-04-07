# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataConversionTool::MenuItemImporter do
  include ServiceLogMatchers

  describe '#import' do
    subject(:import) { importer.import(data: data) }

    let(:menu) { create(:menu) }
    let(:created_records) { Hash.new(0) }
    let(:skipped_records) { Hash.new(0) }
    let(:errors) { [] }
    let(:logs) { [] }
    let(:skipped_keys) { Set.new }
    let(:importer) do
      described_class.new(
        menu: menu,
        created_records: created_records,
        skipped_records: skipped_records,
        logs: logs,
        errors: errors,
        skipped_keys: skipped_keys
      )
    end

    context 'when data is valid' do
      let(:data) { { 'name' => 'X-Burger', 'price' => 12.5 } }

      it 'creates a menu item' do
        expect { import }.to change(menu.menu_items, :count).by(1)
      end

      it 'increments created_records[:items]' do
        expect { import }.to change { created_records[:items] }.by(1)
      end

      it 'does not add any error' do
        import
        expect(errors).to be_empty
      end

      it 'logs success message' do
        import
        expect(logs).to include_log_message("    [✓ SUCCESS] MenuItem 'X-Burger' added")
      end
    end

    context 'when item name is duplicated in the same menu' do
      before { create(:menu_entry, menu: menu, menu_item: create(:menu_item, name: 'X-Burger')) }

      let(:data) { { 'name' => 'X-Burger', 'price' => 9.99 } }

      it 'creates a duplicated item with a modified name' do
        expect { import }.to change(menu.menu_items, :count).by(1)
        expect(menu.menu_items.last.name).to match(/X-Burger \(duplicate .+\)/)
      end

      it 'increments duplicated_items counter' do
        expect { import }.to change { created_records[:duplicated_items] }.by(1)
      end

      it 'logs the duplication warning' do
        import
        expect(logs.any? { |log| log.include?('Duplicate item') }).to be true
      end
    end

    context 'when name is missing' do
      let(:data) { { 'price' => 10 } }

      it 'does not create a menu item' do
        expect { import }.not_to change(menu.menu_items, :count)
      end

      it 'increments skipped_records[:items]' do
        expect { import }.to change { skipped_records[:items] }.by(1)
      end

      it 'adds an error' do
        import
        expect(errors.join).to match(/Failed to create MenuItem/)
      end
    end

    context 'when price is missing' do
      let(:data) { { 'name' => 'Fries' } }

      it 'does not create a menu item' do
        expect { import }.not_to change(menu.menu_items, :count)
      end

      it 'increments skipped_records[:items]' do
        expect { import }.to change { skipped_records[:items] }.by(1)
      end

      it 'adds an error' do
        import
        expect(errors.join).to match(/Failed to create MenuItem/)
      end
    end

    context 'when price is negative' do
      let(:data) { { 'name' => 'Soup', 'price' => -3.0 } }

      it 'does not create a menu item' do
        expect { import }.not_to change(menu.menu_items, :count)
      end

      it 'adds an error and skips the item' do
        expect { import }.to change { skipped_records[:items] }.by(1)
        expect(errors.join).to match(/Failed to create MenuItem/)
      end
    end

    context 'when price is not a number' do
      let(:data) { { 'name' => 'Salad', 'price' => 'free' } }

      it 'does not create a menu item' do
        expect { import }.not_to change(menu.menu_items, :count)
      end

      it 'adds an error and skips the item' do
        expect { import }.to change { skipped_records[:items] }.by(1)
        expect(errors.join).to match(/Failed to create MenuItem/)
      end
    end

    context 'when "name" key is invalid or missing' do
      let(:data) { { 'nome' => 'InvalidKey', 'price' => 10 } }

      it 'skips the item' do
        expect { import }.to change { skipped_records[:items] }.by(1)
        expect(menu.menu_items.count).to eq(0)
      end
    end

    context 'when "price" key is invalid or missing' do
      let(:data) { { 'name' => 'NoPrice', 'preco' => 99.99 } }

      it 'skips the item' do
        expect { import }.to change { skipped_records[:items] }.by(1)
        expect(menu.menu_items.count).to eq(0)
      end
    end

    context 'when menu is nil (orphan menu item)' do
      let(:importer) do
        described_class.new(
          menu: nil,
          created_records: created_records,
          skipped_records: skipped_records,
          logs: logs,
          errors: errors,
          skipped_keys: skipped_keys
        )
      end

      let(:data) { { 'name' => 'Orphan Item', 'price' => 9.99 } }

      it 'does not raise an error and logs orphan menu item' do
        expect { importer.import(data: data) }.not_to raise_error

        expect(errors).to include(
          a_string_matching(/MenuItem 'Orphan Item'.*menu was missing/)
        )

        expect(skipped_records[:items]).to eq(1)
      end
    end
  end
end
