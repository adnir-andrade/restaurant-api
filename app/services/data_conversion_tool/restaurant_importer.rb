module DataConversionTool
  class RestaurantImporter < BaseImporter
    include DataConversionTool::Helpers

    def import(parsed_json)
      @logs = []
      @errors = []
      @skipped_keys = Set.new

      restaurants = parsed_json['restaurants']
      return @logs unless restaurants.is_a?(Array)

      restaurants.each { |restaurant| import_restaurant(data: restaurant) }

      summarize_logs
      @logs
    end

    private

    def import_restaurant(data:)
      restaurant_name = data['name']
      restaurant_menus = data['menus']

      restaurant = create_restaurant(name: restaurant_name)

      menus = restaurant_menus || []
      menus.each { |menu| import_menu(data: menu, restaurant: restaurant) }
    end

    def create_restaurant(name:)
      restaurant = Restaurant.create!(name: name)
      @logs << Logs.restaurant_success(name)
      restaurant
    end

    def import_menu(data:, restaurant:)
      menu_name = data['name']

      return @errors << Logs.menu_warning(menu_name, restaurant.name) if restaurant.menus.exists?(name: menu_name)

      menu = create_menu(name: menu_name, restaurant: restaurant)

      key = KeyFinder.find(data)
      return handle_missing_items_key(data.keys) unless key

      items = wrap_in_array(data[key])
      items.each { |item| import_item(data: item, menu: menu) }
    end

    def create_menu(name:, restaurant:)
      menu = restaurant.menus.create!(name: name)
      @logs << Logs.menu_success(name, restaurant.name)
      menu
    end

    def handle_missing_items_key(keys)
      @errors << Logs.missing_items_key_error
      @skipped_keys.merge(keys - KeyFinder::ALLOWED_ITEM_KEYS)
    end

    def wrap_in_array(value)
      value.is_a?(Array) ? value : [value]
    end

    def import_item(data:, menu:)
      name = data['name']
      price = data['price']

      if MenuItem.exists?(name: name)
        handle_duplicate_item(name: name, price: price, menu: menu)
      else
        create_item(name: name, price: price, menu: menu)
      end
    end

    def handle_duplicate_item(name:, price:, menu:)
      new_name = "#{name} (duplicate #{SecureRandom.hex(3)})"
      menu.menu_items.create!(name: new_name, price: price)
      @logs << Logs.duplicate_item_warning(name, new_name)
    end

    def create_item(name:, price:, menu:)
      menu.menu_items.create!(name: name, price: price)
      @logs << Logs.menu_item_success(name)
    end

    def summarize_logs
      unless @errors.empty?
        @logs << Logs.summarize_warnings_title
        @logs.concat(@errors)
      end

      return if @skipped_keys.empty?

      @logs << Logs.unknown_keys_title
      @logs.concat(@skipped_keys.to_a.sort.map { |k| "  - #{k}" })
    end
  end
end
