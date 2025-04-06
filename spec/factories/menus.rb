# frozen_string_literal: true

FactoryBot.define do
  factory :menu do
    name { Faker::Food.ethnic_category }
    description { Faker::Food.description }
    restaurant

    trait :pizza do
      name { 'Pizzas' }
      description { 'You can never go wrong with a good Italian pizza with cheese and cheese and more cheese.' }
      restaurant
    end

    trait :sushi do
      name { 'Sushi' }
      description { 'Expensive but delicious. Soaking it in soy sauce is optional.' }
      restaurant
    end
  end
end
