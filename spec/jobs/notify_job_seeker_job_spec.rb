require 'rails_helper'

RSpec.describe NotifyJobSeekerJob, type: :job do
  ActiveJob::Base.queue_adapter = :test


  let(:job_seeker) { create(:job_seeker) }
  let(:client) { create(:client) }
  let(:opportunity) { create(:opportunity, client: client) }

  it 'queues a job with job_seeker_id and opportunity_id' do
    expect {
      NotifyJobSeekerJob.perform_later(job_seeker.id, opportunity.id)
    }.to have_enqueued_job.with(job_seeker.id, opportunity.id)
  end
end
