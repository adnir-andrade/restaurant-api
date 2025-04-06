# frozen_string_literal: true

class MenuItem < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  has_many :menu_entries, dependent: :destroy
  has_many :menus, through: :menu_entries
end
