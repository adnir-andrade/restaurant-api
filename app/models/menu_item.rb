# frozen_string_literal: true

class MenuItem < ApplicationRecord
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :menu, optional: true
end
