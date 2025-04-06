module DataConversionTool
  class RestaurantImporter < BaseImporter
    def import(parsed_json)
      restaurants = parsed_json['restaurants']
      return logs unless restaurants.is_a?(Array)

      restaurants.each { |restaurant_data| import_restaurant(data: restaurant_data) }
      summarize_logs
      logs
    end

    private

    def import_restaurant(data:)
      restaurant = create_restaurant(name: data['name'])
      menus = data['menus'] || []

      menu_importer = MenuImporter.new(
        restaurant: restaurant,
        logs: logs,
        errors: errors,
        skipped_keys: skipped_keys
      )

      menus.each { |menu_data| menu_importer.import(data: menu_data) }
    end

    def create_restaurant(name:)
      restaurant = Restaurant.create!(name: name)
      logs << Logs.restaurant_success(name)
      restaurant
    end
  end
end
