# frozen_string_literal: true

class Menu < ApplicationRecord
  # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :name, presence: true, uniqueness: {
    scope: :restaurant_id,
    case_sensitive: false,
    message: 'Menu name must be unique within the same restaurant'
  }
  # rubocop:enable Rails/UniqueValidationWithoutIndex

  belongs_to :restaurant
  has_many :menu_entries, dependent: :destroy
  has_many :menu_items, through: :menu_entries
end
