# frozen_string_literal: true

class Restaurant < ApplicationRecord
  validates :name, presence: true

  has_many :menus, dependent: :destroy
end
