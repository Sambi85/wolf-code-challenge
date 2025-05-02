class OpportunitiesController < ApplicationController
  before_action :set_opportunity, only: [ :apply ]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from StandardError, with: :internal_server_error

  def index
    cache_key = "opportunities:#{params[:search]}:page_#{params[:page]}" # <-- redis caching
    binding.pry
    opportunities = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
      Opportunity.with_client_name # <-- pagination
                 .search_by_title(params[:search])
                 .page(params[:page])
                 .per(10)
                 .map { |opportunity| opportunity.slice("id", "title", "description", "salary", "client_name") }
    end

    total_count = Rails.cache.fetch("opportunities:count:#{params[:search]}") do # aids in pagination
      Opportunity.search_by_title(params[:search]).count
    end

    render json: { opportunities: opportunities, total_count: total_count }
  rescue => e
    Rails.logger.error("[OpportunitiesController#index] #{e.class}: #{e.message}")
    render json: { error: "Unable to load opportunities" }, status: :internal_server_error
  end

  def create
    opportunity = Opportunity.new(opportunity_params)
    opportunity.client = Client.first # Here you would assign a client using auth

    if opportunity.save
      render json: opportunity, status: :created
    else
      Rails.logger.warn("[OpportunitiesController#create] Validation failed: #{opportunity.errors.full_messages.join(', ')}")
      render json: { errors: opportunity.errors.full_messages }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error("[OpportunitiesController#create] #{e.class}: #{e.message}")
    render json: { error: "Something went wrong while creating the opportunity" }, status: :internal_server_error
  end

  def apply
    job_seeker = JobSeeker.first # Here you would assign a job seeker using auth
    job_application = @opportunity.job_applications.new(job_seeker: job_seeker)

    if job_application.save
      # Notify job seeker via background job (this doesn't change)
      NotifyJobSeekerJob.perform_async(job_seeker.id, @opportunity.id)
      render json: { message: "Application successful" }, status: :ok
    else
      Rails.logger.warn("[OpportunitiesController#apply] Validation failed: #{job_application.errors.full_messages.join(', ')}")
      render json: { errors: job_application.errors.full_messages }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error("[OpportunitiesController#apply] #{e.class}: #{e.message}")
    render json: { error: "Failed to apply to the opportunity" }, status: :internal_server_error
  end

  private

  def set_opportunity
    @opportunity = Opportunity.find(params[:id])
  end

  def opportunity_params
    params.require(:opportunity).permit(:title, :description, :salary)
  end

  def record_not_found(exception)
    Rails.logger.warn("[OpportunitiesController] Record not found: #{exception.message}")
    render json: { error: "Opportunity not found" }, status: :not_found
  end

  def internal_server_error(exception)
    Rails.logger.error("[OpportunitiesController] Internal error: #{exception.message}")
    render json: { error: "Internal server error" }, status: :internal_server_error
  end
end
