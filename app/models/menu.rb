# frozen_string_literal: true

class Menu < ApplicationRecord
  validates :name, presence: true

  has_many :menu_entries, dependent: :destroy
  has_many :menu_items, through: :menu_entries
end
