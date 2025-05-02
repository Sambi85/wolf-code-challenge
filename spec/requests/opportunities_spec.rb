require 'rails_helper'
require 'sidekiq/testing'
include ActiveJob::TestHelper

RSpec.describe "Opportunities API", type: :request do
  before(:each) do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    Rails.cache.clear
  end

  after(:each) do
    Sidekiq::Worker.clear_all
    Rails.cache.clear
  end

  let(:client) { create(:client) }
  let(:job_seeker) { create(:job_seeker) }
  let!(:opportunity1) { create(:opportunity, title: "Ruby Developer", client: client) }
  let!(:opportunity2) { create(:opportunity, title: "React Developer", client: client) }
  let!(:opportunity3) { create(:opportunity, title: "Rust Developer", client: client) }

  describe "GET /opportunities" do
    it "returns paginated opportunities with client name and uses caching" do
      get "/opportunities", params: { search: "Developer", page: 1 }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["opportunities"].length).to eq(3)
      expect(json["total_count"]).to eq(3)

      cache_key = "opportunities:Developer:page_1"
      expect(Rails.cache.exist?(cache_key)).to be true
    end
  end

  describe "POST /opportunities" do
    it "creates a new opportunity" do
      post "/opportunities", params: {
        opportunity: {
          title: "Full Stack Engineer",
          description: "Develop full stack applications",
          salary: 120000
        }
      }

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)
      expect(json["title"]).to eq("Full Stack Engineer")
      expect(json["description"]).to eq("Develop full stack applications")
      expect(json["salary"]).to eq('120000.0')
    end

    it "fails to create an opportunity with invalid params" do
      post "/opportunities", params: { opportunity: { title: nil, description: "Invalid Opportunity", salary: nil } }

      expect(response).to have_http_status(:unprocessable_entity)

      json = JSON.parse(response.body)
      expect(json["errors"]).to include("Title can't be blank", "Salary can't be blank")
    end
  end

  describe "POST /opportunities/:id/apply" do
    it "applies to an opportunity and enqueues a Sidekiq job" do
      post "/opportunities/#{opportunity1.id}/apply", headers: { "X-Job-Seeker-Email" => job_seeker.email }
      expect(response).to have_http_status(:ok)
      expect(enqueued_jobs.size).to eq(1)
      expect(JobApplication.count).to eq(1)
    end


    it "fails to apply to an opportunity with validation errors" do
      allow_any_instance_of(JobApplication).to receive(:save).and_return(false)

      post "/opportunities/#{opportunity1.id}/apply", headers: { "X-Job-Seeker-Email" => job_seeker.email }

      expect(response).to have_http_status(:unprocessable_entity)

      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
    end
  end
end
