FactoryBot.define do
  factory :job_application do
    association :job_seeker
    association :opportunity
  end
end
