# frozen_string_literal: true

module SerializerHelpers
  def serialized_menu(menu)
    {
      id: menu.id,
      name: menu.name,
      description: menu.description
    }.as_json
  end
end
