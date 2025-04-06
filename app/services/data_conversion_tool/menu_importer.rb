# frozen_string_literal: true

module DataConversionTool
  class MenuImporter < BaseImporter
    def initialize(restaurant:, logs: nil, errors: nil, skipped_keys: nil)
      super(logs: logs, errors: errors, skipped_keys: skipped_keys)
      @restaurant = restaurant
    end

    def import(data:)
      menu_name = data['name']
      return errors << Logs.menu_warning(menu_name, @restaurant.name) if @restaurant.menus.exists?(name: menu_name)

      menu = create_menu(name: menu_name)
      key = KeyFinder.find(data)
      return handle_missing_items_key(data.keys) unless key

      items = wrap_in_array(data[key])
      item_importer = MenuItemImporter.new(
        menu: menu,
        logs: logs,
        errors: errors,
        skipped_keys: skipped_keys
      )
      items.each { |item| item_importer.import(data: item) }
    end

    private

    def create_menu(name:)
      menu = @restaurant.menus.create!(name: name)
      logs << Logs.menu_success(name, @restaurant.name)
      menu
    end

    def handle_missing_items_key(keys)
      errors << Logs.missing_items_key_error
      skipped_keys.merge(keys - KeyFinder::ALLOWED_ITEM_KEYS)
    end

    def wrap_in_array(value)
      value.is_a?(Array) ? value : [value]
    end
  end
end
