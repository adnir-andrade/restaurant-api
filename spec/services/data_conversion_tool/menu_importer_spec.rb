# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataConversionTool::MenuImporter do
  include ServiceLogMatchers

  describe '#import' do
    subject(:import) { importer.import(data: data) }

    let(:restaurant) { create(:restaurant) }
    let(:created_records) { Hash.new(0) }
    let(:skipped_records) { Hash.new(0) }
    let(:errors) { [] }
    let(:logs) { [] }
    let(:skipped_keys) { Set.new }

    let(:importer) do
      described_class.new(
        restaurant: restaurant,
        created_records: created_records,
        skipped_records: skipped_records,
        logs: logs,
        errors: errors,
        skipped_keys: skipped_keys
      )
    end

    context 'when data is valid' do
      let(:data) do
        {
          'name' => 'Burgers',
          'description' => 'Classic American burgers.',
          'menu_items' => [
            { 'name' => 'X-Burger', 'price' => 10.0 }
          ]
        }
      end

      it 'creates a menu' do
        expect { import }.to change(restaurant.menus, :count).by(1)
      end

      it 'creates the associated menu item' do
        import
        menu = restaurant.menus.find_by(name: 'Burgers')
        expect(menu.menu_items.count).to eq(1)
      end

      it 'increments created_records[:menus]' do
        expect { import }.to change { created_records[:menus] }.by(1)
      end

      it 'persists the menu item with correct attributes' do
        import
        menu_item = restaurant.menus.first.menu_items.first
        expect(menu_item.name).to eq('X-Burger')
        expect(menu_item.price).to eq(10.0)
      end

      it 'does not add errors' do
        import
        expect(errors).to be_empty
      end

      it 'logs a success message' do
        import
        expect(logs.join).to include('✓ SUCCESS')
      end
    end

    context 'when multiple menu items are provided' do
      let(:data) do
        {
          'name' => 'Combo Menu',
          'menu_items' => [
            { 'name' => 'Burger', 'price' => 12.0 },
            { 'name' => 'Fries', 'price' => 5.0 },
            { 'name' => 'Soda', 'price' => 4.0 }
          ]
        }
      end

      it 'creates all menu items' do
        import
        menu = restaurant.menus.find_by(name: 'Combo Menu')
        expect(menu.menu_items.count).to eq(3)
        expect(menu.menu_items.map(&:name)).to contain_exactly('Burger', 'Fries', 'Soda')
      end
    end

    context 'when menu items key is aliased (e.g. "dishes")' do
      let(:data) do
        {
          'name' => 'Burgers',
          'dishes' => [
            { 'name' => 'X-Burger', 'price' => 10.0 }
          ]
        }
      end

      it 'creates menu and associated item' do
        expect { import }.to change(restaurant.menus, :count).by(1)
        expect(created_records[:menus]).to eq(1)
      end
    end

    context 'when some menu items are invalid' do
      let(:data) do
        {
          'name' => 'Mixed Menu',
          'menu_items' => [
            { 'name' => 'Valid Item', 'price' => 12.0 },
            { 'name' => '', 'price' => 5.0 },
            { 'price' => 7.0 },
            { 'name' => 'Negative', 'price' => -2.0 }
          ]
        }
      end

      it 'creates only the valid items' do
        import
        menu = restaurant.menus.find_by(name: 'Mixed Menu')
        expect(menu.menu_items.count).to eq(1)
        expect(menu.menu_items.first.name).to eq('Valid Item')
      end

      it 'logs errors for the invalid items' do
        import
        expect(errors.join).to include('Price must be greater than or equal to 0')
      end

      it 'increments skipped_records[:items]' do
        import
        expect(skipped_records[:items]).to eq(3)
      end
    end

    context 'when menu already exists for the same restaurant' do
      before do
        create(:menu, name: 'Burgers', restaurant: restaurant)
      end

      let(:data) do
        {
          'name' => 'Burgers',
          'menu_items' => [{ 'name' => 'X-Burger', 'price' => 10.0 }]
        }
      end

      it 'does not create a new menu' do
        expect { import }.not_to change(restaurant.menus, :count)
      end

      it 'adds a warning to errors' do
        import
        expect(errors.join).to include('already exists for restaurant')
      end
    end

    context 'when data is missing "name"' do
      let(:data) do
        {
          'description' => 'Missing name',
          'menu_items' => [{ 'name' => 'X-Burger', 'price' => 10.0 }]
        }
      end

      it 'does not create a menu' do
        expect { import }.not_to change(restaurant.menus, :count)
      end

      it 'adds error about missing name' do
        import
        expect(errors.join).to include('Name can\'t be blank')
        expect(skipped_records[:menus]).to eq(1)
      end
    end

    context 'when "name" is present but empty' do
      let(:data) do
        {
          'name' => '',
          'menu_items' => [{ 'name' => 'X-Burger', 'price' => 10.0 }]
        }
      end

      it 'does not create a menu' do
        expect { import }.not_to change(restaurant.menus, :count)
      end

      it 'adds error about blank name' do
        import
        expect(errors.join).to include('Name can\'t be blank')
        expect(skipped_records[:menus]).to eq(1)
      end
    end

    context 'when menu has no recognizable menu items key' do
      let(:data) do
        {
          'name' => 'Drinks',
          'stuff' => [{ 'name' => 'Coke', 'price' => 5.0 }],
          'foo' => 'bar'
        }
      end

      it 'creates the menu anyway' do
        expect { import }.to change(restaurant.menus, :count).by(1)
      end

      it 'adds a warning to errors' do
        import
        expect(errors.join).to include('No valid items key found')
      end

      it 'does not create any menu items' do
        import
        menu = restaurant.menus.find_by(name: 'Drinks')
        expect(menu.menu_items).to be_empty
      end
    end
  end
end
