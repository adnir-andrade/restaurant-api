# frozen_string_literal: true

class MenuSerializer < ActiveModel::Serializer
  attributes :id, :name, :description
end
