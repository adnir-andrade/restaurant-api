# frozen_string_literal: true

module DataConversionTool
  class RestaurantImporter < BaseImporter
    ALLOWED_RESTAURANT_KEYS = %w[restaurants].freeze

    def import(parsed_json)
      restaurants = extract_restaurants_from(parsed_json)
      return { errors: @errors, logs: @logs } if restaurants.empty?

      restaurants.each { |restaurant_data| import_restaurant(data: restaurant_data) }
      summarize_logs

      {
        created_records: @created_records,
        skipped_records: @skipped_records,
        errors: @errors,
        skipped_keys: @skipped_keys,
        logs: @logs
      }
    end

    private

    def extract_restaurants_from(data)
      restaurant_key = data.keys.find { |key| self.class::ALLOWED_RESTAURANT_KEYS.include?(key) }

      return handle_missing_root_key unless restaurant_key

      data[restaurant_key]
    end

    def handle_missing_root_key
      @errors << Logs.missing_restaurants_key_error(self.class::ALLOWED_RESTAURANT_KEYS)
      []
    end

    def import_restaurant(data:)
      restaurant = create_restaurant(name: data['name'])
      return unless restaurant

      menus = data['menus'] || []

      menu_importer = MenuImporter.new(
        restaurant: restaurant,
        created_records: @created_records,
        skipped_records: @skipped_records,
        logs: logs,
        errors: errors,
        skipped_keys: skipped_keys
      )

      menus.each { |menu_data| menu_importer.import(data: menu_data) }
    end

    def create_restaurant(name:)
      restaurant = Restaurant.new(name: name)

      if restaurant.save
        @logs << Logs.restaurant_success(name)
        @created_records[:restaurants] += 1
        return restaurant
      else
        @errors << Logs.restaurant_creation_failed(name, restaurant.errors.full_messages.to_sentence)
        @skipped_records[:restaurants] += 1
      end

      nil
    rescue StandardError => e
      @errors << Logs.restaurant_creation_exception(name, e.message)
      nil
    end
  end
end
