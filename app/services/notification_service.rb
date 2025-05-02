class NotificationService
  def self.send_notification(job_seeker, opportunity)
    Rails.logger.info "📢 Notifying #{job_seeker.email} about #{opportunity.title}"
    # In real life: send email, SMS, push, etc.
  end
end
