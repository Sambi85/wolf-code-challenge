require 'rails_helper'
require_relative '../../app/models/opportunity.rb'

RSpec.describe Opportunity do
  let(:client) { create(:client) }
  let(:opportunity) { create(:opportunity, client: client) }

  describe 'associations' do
    it 'belongs to a client' do
      expect(opportunity.client).to eq(client)
    end

    it 'has many job applications' do
      job_application = create(:job_application, opportunity: opportunity)
      expect(opportunity.job_applications).to include(job_application)
    end
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(opportunity).to be_valid
    end

    it 'is invalid without a title' do
      opportunity.title = nil
      expect(opportunity).not_to be_valid
    end

    it 'is invalid without a client' do
      opportunity.client = nil
      expect(opportunity).not_to be_valid
    end
  end
end
