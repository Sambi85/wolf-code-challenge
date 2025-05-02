require 'rails_helper'

RSpec.describe JobApplication, type: :model do
  let(:job_seeker) { create(:job_seeker) }
  let(:client) { create(:client) }
  let(:opportunity) { create(:opportunity, client: client) }
  let(:job_application) { create(:job_application, job_seeker: job_seeker, opportunity: opportunity) }

  describe 'associations' do
    it 'belongs to a job seeker' do
      expect(job_application.job_seeker).to eq(job_seeker)
    end

    it 'belongs to an opportunity' do
      expect(job_application.opportunity).to eq(opportunity)
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(job_application).to be_valid
    end

    it 'is invalid without a job_seeker_id' do
      job_application.job_seeker = nil
      expect(job_application).not_to be_valid
    end

    it 'is invalid without an opportunity_id' do
      job_application.opportunity = nil
      expect(job_application).not_to be_valid
    end
  end
end
