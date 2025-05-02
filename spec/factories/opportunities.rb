FactoryBot.define do
  factory :opportunity do
    title { "Software Developer" }
    description { "Developing software applications." }
    salary { 100000 }
    association :client
  end
end
