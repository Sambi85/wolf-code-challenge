class NotifyJobSeekerJob < ApplicationJob
  queue_as :default

  def perform(job_seeker_id, opportunity_id)
    Rails.logger.info "NotifyJobSeekerJob started for JobSeeker ID: #{job_seeker_id}, Opportunity ID: #{opportunity_id}"

    job_seeker = JobSeeker.find(job_seeker_id)
    opportunity = Opportunity.find(opportunity_id)

    NotificationService.send_notification(job_seeker, opportunity)

    Rails.logger.info "Notification sent to JobSeeker #{job_seeker.id} for Opportunity #{opportunity.id}"
  rescue => e
    Rails.logger.error "NotifyJobSeekerJob failed: #{e.message}"
    raise e
  end
end
