# frozen_string_literal: true

module DataConversionTool
  class MenuItemImporter < BaseImporter
    def initialize(menu:, **)
      super(**)
      @menu = menu
    end

    def import(data:)
      return handle_orphan_item(data) unless @menu&.persisted?

      name = data['name']
      price = data['price']

      if MenuItem.exists?(name: name)
        import_duplicate_item(name, price)
      else
        import_unique_item(name, price)
      end
    end

    private

    def handle_orphan_item(data)
      @errors << Logs.orphan_menu_item(data['name'], data['price'])
      @skipped_records[:items] += 1
    end

    def import_duplicate_item(name, price)
      new_name = "#{name} (duplicate #{SecureRandom.hex(3)})"
      create_item(name: new_name, price: price) do
        @created_records[:duplicated_items] += 1
        logs << Logs.duplicate_item_warning(name, new_name)
      end
    end

    def import_unique_item(name, price)
      create_item(name: name, price: price) do
        @created_records[:items] += 1
        logs << Logs.menu_item_success(name)
      end
    end

    def create_item(name:, price:)
      item = MenuItem.new(name: name, price: price)

      if item.save
        MenuEntry.create!(menu: @menu, menu_item: item)

        yield if block_given?
        return item
      else
        @errors << Logs.menu_item_creation_failed(name, price, item.errors.full_messages.to_sentence)
        @skipped_records[:items] += 1
      end

      nil
    rescue StandardError => e
      @errors << Logs.menu_item_creation_exception(name, price, e.message)
      nil
    end
  end
end
