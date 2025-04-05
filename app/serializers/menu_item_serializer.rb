# frozen_string_literal: true

class MenuItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :price
  has_one :menu

  def price
    format('%.2f', object.price)
  end
end
