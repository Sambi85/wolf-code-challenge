require 'rails_helper'

RSpec.describe JobSeeker, type: :model do
  it 'is valid with valid attributes' do
    job_seeker = JobSeeker.new(name: 'Alice', email: 'alice@example.com')
    expect(job_seeker).to be_valid
  end

  it 'is invalid without a name' do
    job_seeker = JobSeeker.new(name: nil, email: 'alice@example.com')
    expect(job_seeker).not_to be_valid
  end

  it 'is invalid with an improperly formatted email' do
    job_seeker = JobSeeker.new(name: 'Alice', email: 'invalid-email')
    expect(job_seeker).not_to be_valid
  end

  it 'is invalid with a duplicate email' do
    JobSeeker.create!(name: 'Original', email: 'alice@example.com')
    duplicate = JobSeeker.new(name: 'Copy', email: 'alice@example.com')
    expect(duplicate).not_to be_valid
  end
end
