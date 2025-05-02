FactoryBot.define do
  factory :job_seeker do
    name { "Test Seeker" }
    email { "test@example.com" }  # Use a valid email
    phone_number { "1234567890" }
  end
end
