# frozen_string_literal: true

module DataConversionTool
  module Helpers
    module Logs
      module_function

      def restaurant_success(name)
        "[✓ SUCCESS] Restaurant '#{name}' imported"
      end

      def menu_success(name, restaurant_name)
        "  [✓ SUCCESS] Menu '#{name}' added to '#{restaurant_name}'"
      end

      def menu_warning(name, restaurant_name)
        "[⚠ WARNING]️ Menu '#{name}' already exists for restaurant '#{restaurant_name}', skipping..."
      end

      def missing_items_key_error(menu_name)
        "[X ERROR]️ No valid items key found in menu '#{menu_name}'"
      end

      def duplicate_item_warning(name, new_name)
        "    [⚠ WARNING]️ Duplicate item '#{name}' renamed to '#{new_name}'"
      end

      def menu_item_success(name)
        "    [✓ SUCCESS] MenuItem '#{name}' added"
      end

      def summarize_warnings_title
        "\n--- Import completed with warnings: ---"
      end

      def unknown_keys_title
        "\n--- ⚠ Unknown keys found " \
          '(consider adding them to ALLOWED_ITEM_KEYS ' \
          'in DataConversionTool::Helpers::KeyFinder):'
      end

      def unknown_key_item(key)
        "  - #{key}"
      end
    end
  end
end
