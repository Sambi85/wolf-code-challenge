require 'rails_helper'

RSpec.describe OpportunitySearchService, type: :service do
  before(:each) do
    Opportunity.delete_all
    JobApplication.delete_all
    Rails.cache.clear
    Rails.cache.redis.flushdb if Rails.cache.respond_to?(:redis)
  end

  after(:each) do
    Sidekiq::Worker.clear_all
    Rails.cache.clear
  end

  let(:client) { create(:client) }
  let!(:opportunity1) { create(:opportunity, title: "Ruby Developer", client: client) }
  let!(:opportunity2) { create(:opportunity, title: "React Developer", client: client) }
  let!(:opportunity3) { create(:opportunity, title: "Rust Developer", client: client) }

  describe '#call' do
    context 'with search and pagination' do
      it 'returns opportunities that match the search term' do
        Rails.cache.clear
        search_service = OpportunitySearchService.new(search: "Developer", page: 1)

        result = search_service.call

        expect(result[:opportunities].count).to eq(3)
        expect(result[:total_count]).to eq(3)
        expect(result[:opportunities].map { |op| op['title'] }).to contain_exactly("Ruby Developer", "React Developer", "Rust Developer")
      end

      it 'paginates the opportunities' do
        Rails.cache.clear
        search_service = OpportunitySearchService.new(search: "Developer", page: 1)

        result = search_service.call

        expect(result[:opportunities].count).to eq(3)
        expect(result[:total_count]).to eq(3)
      end
    end

    context 'when there are no results' do
      it 'returns an empty list when no opportunities match the search' do
        search_service = OpportunitySearchService.new(search: "Nonexistent", page: 1)

        result = search_service.call

        expect(result[:opportunities]).to be_empty
        expect(result[:total_count]).to eq(0)
      end
    end
  end
end
