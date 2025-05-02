module Applications
  class ApplyToOpportunity
    def initialize(opportunity:, job_seeker:)
      @opportunity = opportunity
      @job_seeker = job_seeker
    end

    def call
      job_application = @opportunity.job_applications.new(job_seeker: @job_seeker)

      if job_application.save
        NotifyJobSeekerJob.perform_later(@job_seeker.id, @opportunity.id)
        Result.success(message: "Application successful")
      else
        Result.failure(errors: job_application.errors.full_messages)
      end
    end
  end
end
