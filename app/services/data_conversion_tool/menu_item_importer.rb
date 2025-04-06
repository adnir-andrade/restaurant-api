# frozen_string_literal: true

module DataConversionTool
  class MenuItemImporter < BaseImporter
    def initialize(menu:, logs: nil, errors: nil, skipped_keys: nil)
      super(logs: logs, errors: errors, skipped_keys: skipped_keys)
      @menu = menu
    end

    def import(data:)
      name = data['name']
      price = data['price']

      if MenuItem.exists?(name: name)
        handle_duplicate_item(name: name, price: price)
      else
        create_item(name: name, price: price)
      end
    end

    private

    def handle_duplicate_item(name:, price:)
      new_name = "#{name} (duplicate #{SecureRandom.hex(3)})"
      @menu.menu_items.create!(name: new_name, price: price)
      logs << Logs.duplicate_item_warning(name, new_name)
    end

    def create_item(name:, price:)
      @menu.menu_items.create!(name: name, price: price)
      logs << Logs.menu_item_success(name)
    end
  end
end
