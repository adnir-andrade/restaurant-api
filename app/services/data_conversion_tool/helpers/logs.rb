# frozen_string_literal: true

module DataConversionTool
  module Helpers
    module Logs
      module_function

      def restaurant_success(name)
        "[✓ SUCCESS] Restaurant '#{name}' imported"
      end

      def restaurant_creation_failed(name, errors)
        "[X ERROR]️ Failed to create restaurant '#{name}': #{errors}"
      end

      def restaurant_creation_exception(name, exception)
        "[X ERROR]️ Unexpected error creating restaurant '#{name}': #{exception}"
      end

      def menu_success(name, restaurant_name)
        "  [✓ SUCCESS] Menu '#{name}' added to '#{restaurant_name}'"
      end

      def menu_warning(name, restaurant_name)
        "[⚠ WARNING]️ Menu '#{name}' already exists for restaurant '#{restaurant_name}', skipping..."
      end

      def self.missing_restaurants_key_error(available_keys)
        "[X ERROR]️ Missing required root key: 'restaurants'. Please make sure your JSON has one of the following as a top-level key: #{available_keys.join(', ')}"
      end

      def self.missing_items_key_error(restaurant_name, menu_name, available_keys)
        "[X ERROR]️ No valid items key found in restaurant '#{restaurant_name}' menu '#{menu_name}'. Available keys: #{available_keys.join(', ')}"
      end

      def duplicate_item_warning(name, new_name)
        "    [⚠ WARNING]️ Duplicate item '#{name}' renamed to '#{new_name}'"
      end

      def menu_item_success(name)
        "    [✓ SUCCESS] MenuItem '#{name}' added"
      end

      def summarize_warnings_title
        '--- Import completed with warnings: ---'
      end

      def unknown_keys_title
        '--- ⚠ Unknown keys found ' \
          '(consider adding them to ALLOWED_ITEM_KEYS ' \
          'in DataConversionTool::Helpers::KeyFinder):'
      end

      def unknown_key_item(key)
        "  - #{key}"
      end
    end
  end
end
