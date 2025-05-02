class OpportunitiesController < ApplicationController
  before_action :set_opportunity, only: [ :apply ]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from StandardError, with: :internal_server_error

  def index
    search_service = OpportunitySearchService.new(search: params[:search], page: params[:page])
    result = search_service.call

    render json: result
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
    job_seeker = current_job_seeker # Replace with actual auth lookup
    result = Applications::ApplyToOpportunity.new(
      opportunity: @opportunity,
      job_seeker: job_seeker
    ).call

    if result.success?
      render json: { message: result.value[:message] }, status: :ok
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  private

  def current_job_seeker
    JobSeeker.find_by(email: request.headers["X-Job-Seeker-Email"]) || JobSeeker.first # dummy for auth
  end

  def set_opportunity
    @opportunity = Opportunity.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    record_not_found(e)
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
