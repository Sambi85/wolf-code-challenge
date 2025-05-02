# Seed data for Clients
Rails.logger.info "Creating Clients..."

client1 = Client.create(name: 'TechCorp')
Rails.logger.info "Created Client: #{client1.name}"

client2 = Client.create(name: 'InnoSoft')
Rails.logger.info "Created Client: #{client2.name}"

# Seed data for Job Seekers
Rails.logger.info "Creating Job Seekers..."

job_seeker1 = JobSeeker.create(name: 'John Doe', email: 'john.doe@example.com', phone_number: '123-456-7890')
Rails.logger.info "Created Job Seeker: #{job_seeker1.name}"

job_seeker2 = JobSeeker.create(name: 'Jane Smith', email: 'jane.smith@example.com', phone_number: '987-654-3210')
Rails.logger.info "Created Job Seeker: #{job_seeker2.name}"

# Seed data for Opportunities
Rails.logger.info "Creating Opportunities..."

opportunity1 = Opportunity.create(title: 'Software Developer', description: 'Build amazing software for the web.', salary: 80000, client: client1)
Rails.logger.info "Created Opportunity: #{opportunity1.title}"

opportunity2 = Opportunity.create(title: 'Front-End Developer', description: 'Create beautiful web interfaces.', salary: 70000, client: client2)
Rails.logger.info "Created Opportunity: #{opportunity2.title}"

opportunity3 = Opportunity.create(title: 'Full Stack Developer', description: 'Work on both front-end and back-end systems.', salary: 90000, client: client1)
Rails.logger.info "Created Opportunity: #{opportunity3.title}"

# Seed data for Job Applications
Rails.logger.info "Creating Job Applications..."

JobApplication.create(job_seeker: job_seeker1, opportunity: opportunity1)
Rails.logger.info "Created Job Application for #{job_seeker1.name} to #{opportunity1.title}"

JobApplication.create(job_seeker: job_seeker2, opportunity: opportunity2)
Rails.logger.info "Created Job Application for #{job_seeker2.name} to #{opportunity2.title}"

JobApplication.create(job_seeker: job_seeker1, opportunity: opportunity3)
Rails.logger.info "Created Job Application for #{job_seeker1.name} to #{opportunity3.title}"

Rails.logger.info "Seeding completed successfully!"
