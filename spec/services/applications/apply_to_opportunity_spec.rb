require "rails_helper"

RSpec.describe Applications::ApplyToOpportunity, type: :service do
  let(:job_seeker) { JobSeeker.create!(name: "Jane", email: "jane@example.com", phone_number: "1234567890") }
  let(:client)     { Client.create!(name: "Acme") }
  let(:opportunity) { Opportunity.create!(title: "Dev", description: "Dev job", salary: 100000, client: client) }

  it "creates a job application" do
    result = described_class.new(opportunity: opportunity, job_seeker: job_seeker).call

    expect(result).to be_success
    expect(result.value[:message]).to eq("Application successful")
  end
end
