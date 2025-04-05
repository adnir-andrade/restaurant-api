# frozen_string_literal: true

FactoryBot.define do
  factory :menu_item do
    name { Faker::Food.dish }
    description { Faker::Food.description }
    price { Faker::Number.decimal(l_digits: 2) }

    trait :with_menu do
      association :menu
    end

    trait :pancake do
      name { 'Pancake' }
      description { 'I miss pancakes...' }
      price { 7.77 }
    end
  end
end
