FactoryBot.define do
  factory :menu do
    name { Faker::Food.ethnic_category }
    description { Faker::Food.description }

    trait :pizza do
      name { 'Pizzas' }
      description { 'You can never go wrong with a good Italian pizza with cheese and cheese and more cheese.' }
    end

    trait :sushi do
      name { 'Sushi' }
      description { 'Expensive but delicious. Soaking it in soy sauce is optional.' }
    end
  end
end
