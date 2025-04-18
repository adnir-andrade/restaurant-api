# frozen_string_literal: true

module DataConversionTool
  class MenuImporter < BaseImporter
    ALLOWED_ITEM_KEYS = %w[menu_items items dishes pratos plats].freeze

    def initialize(restaurant:, **)
      super(**)
      @restaurant = restaurant
    end

    def import(data:)
      menu_name = data['name']
      return handle_existing_menu(data['name']) if menu_exists?(data['name'])

      menu = create_menu(name: menu_name)
      return unless menu

      items = extract_items_from(data)
      import_items(menu, items) if items
    end

    private

    def handle_existing_menu(menu_name)
      errors << Logs.menu_warning(menu_name, @restaurant.name)
    end

    def menu_exists?(menu_name)
      @restaurant.menus.exists?(name: menu_name)
    end

    def create_menu(name:)
      menu = @restaurant.menus.new(name: name)

      if menu.save
        handle_menu_success(menu)
      else
        handle_menu_failure(menu)
      end

      menu
    rescue StandardError => e
      handle_menu_exception(name, e)
      nil
    end

    def handle_menu_success(menu)
      @logs << Logs.menu_success(menu.name, @restaurant.name)
      @created_records[:menus] += 1
    end

    def handle_menu_failure(menu)
      @errors << Logs.menu_creation_failed(menu.name, @restaurant.name, menu.errors.full_messages.to_sentence)
      @skipped_records[:menus] += 1
    end

    def handle_menu_exception(name, error)
      @errors << Logs.menu_creation_exception(name, @restaurant.name, error.message)
    end

    def extract_items_from(data)
      item_key = data.keys.find { |key| self.class::ALLOWED_ITEM_KEYS.include?(key) }

      return handle_missing_items_key(data.keys, data['name']) unless item_key

      wrap_in_array(data[item_key])
    end

    def handle_missing_items_key(all_keys, menu_name)
      unknown_keys = all_keys - self.class::ALLOWED_ITEM_KEYS - %w[name]

      errors << Logs.missing_items_key_error(@restaurant.name, menu_name, all_keys)

      skipped_keys.merge(unknown_keys)
      []
    end

    def wrap_in_array(value)
      value.is_a?(Array) ? value : [value]
    end

    def import_items(menu, items)
      item_importer = MenuItemImporter.new(
        menu: menu,
        created_records: @created_records,
        skipped_records: @skipped_records,
        logs: logs,
        errors: errors,
        skipped_keys: skipped_keys
      )

      items.each { |item| item_importer.import(data: item) }
    end
  end
end
