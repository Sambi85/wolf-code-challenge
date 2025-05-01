class OpportunitiesController < ApplicationController
  before_action :set_opportunity, only: [ :apply ]

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from StandardError, with: :internal_server_error

  def index
    opportunities = Opportunity.with_client_name
                               .search_by_title(params[:search])
                               .page(params[:page])
                               .per(10)

    render json: opportunities
  rescue => e
    Rails.logger.error("[OpportunitiesController#index] #{e.class}: #{e.message}")
    render json: { error: "Unable to load opportunities" }, status: :internal_server_error
  end

  def create
    opportunity = Opportunity.new(opportunity_params)
    opportunity.client = current_client

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
    job_application = @opportunity.applications.new(job_seeker: current_job_seeker)

    if job_application.save
      NotifyJobSeekerJob.perform_async(current_job_seeker.id, @opportunity.id)
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
