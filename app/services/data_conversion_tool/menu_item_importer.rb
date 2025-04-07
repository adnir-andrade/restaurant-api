# frozen_string_literal: true

module DataConversionTool
  class MenuItemImporter < BaseImporter
    def initialize(menu:, **)
      super(**)
      @menu = menu
    end

    def import(data:)
      name = data['name']
      price = data['price']

      if MenuItem.exists?(name: name)
        new_name = "#{name} (duplicate #{SecureRandom.hex(3)})"
        create_item(name: new_name, price: price) do
          @created_records[:duplicated_items] += 1
          logs << Logs.duplicate_item_warning(name, new_name)
        end
      else
        create_item(name: name, price: price) do
          @created_records[:items] += 1
          logs << Logs.menu_item_success(name)
        end
      end
    end

    private

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
