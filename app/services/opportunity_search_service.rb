class OpportunitySearchService
  def initialize(search:, page:)
    @search = search
    @page = page
  end

  def call
    cache_key = "opportunities:#{@search}:page_#{@page}"

    opportunities = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
      fetch_opportunities
    end

    total_count = Rails.cache.fetch("opportunities:count:#{@search}") do
      Opportunity.search_by_title(@search).count
    end

    {
      opportunities: opportunities,
      total_count: total_count
    }
  end

  private

  def fetch_opportunities
    Opportunity.with_client_name
               .search_by_title(@search)
               .page(@page)
               .per(10)
               .map { |opportunity| opportunity.slice("id", "title", "description", "salary", "client_name") }
  end
end
