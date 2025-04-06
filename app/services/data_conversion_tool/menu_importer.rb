# frozen_string_literal: true

module DataConversionTool
  class MenuImporter < BaseImporter
    def initialize(restaurant:, logs: nil, errors: nil, skipped_keys: nil)
      super(logs: logs, errors: errors, skipped_keys: skipped_keys)
      @restaurant = restaurant
    end

    def import(data:)
      menu_name = data['name']
      return handle_existing_menu(data['name']) if menu_exists?(data['name'])

      menu = create_menu(name: menu_name)
      items = extract_items_from(data)
      import_items(menu, items)
    end

    private

    def handle_existing_menu(menu_name)
      errors << Logs.menu_warning(menu_name, @restaurant.name)
    end

    def menu_exists?(menu_name)
      @restaurant.menus.exists?(name: menu_name)
    end

    def create_menu(name:)
      menu = @restaurant.menus.create!(name: name)
      logs << Logs.menu_success(name, @restaurant.name)
      menu
    end

    def extract_items_from(data)
      key = KeyFinder.find(data)
      return handle_missing_items_key(data.keys) unless key

      wrap_in_array(data[key])
    end

    def handle_missing_items_key(keys)
      errors << Logs.missing_items_key_error
      skipped_keys.merge(keys - KeyFinder::ALLOWED_ITEM_KEYS)
    end

    def wrap_in_array(value)
      value.is_a?(Array) ? value : [value]
    end

    def import_items(menu, items)
      item_importer = MenuItemImporter.new(
        menu: menu,
        logs: logs,
        errors: errors,
        skipped_keys: skipped_keys
      )

      items.each { |item| item_importer.import(data: item) }
    end
  end
end
