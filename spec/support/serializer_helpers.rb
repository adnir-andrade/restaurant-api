# frozen_string_literal: true

module SerializerHelpers
  def serialized_menu(menu)
    {
      id: menu.id,
      name: menu.name,
      description: menu.description
    }.as_json
  end

  def serialized_menu_item(menu_item)
    {
      id: menu_item.id,
      name: menu_item.name,
      description: menu_item.description,
      price: format('%.2f', menu_item.price),
      menus: menu_item.menus.map { |menu| serialized_menu(menu) }
    }.as_json
  end
end
