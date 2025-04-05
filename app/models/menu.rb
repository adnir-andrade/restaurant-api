# frozen_string_literal: true

class Menu < ApplicationRecord
  validates :name, presence: true

  has_many :menu_items, dependent: :nullify
end
