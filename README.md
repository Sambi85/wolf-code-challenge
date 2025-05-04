# README - Wolf Api + Rate Limiter Challenge

# Important:
- please note, both assigned tasks can be found this repo

# 🛠 Setup
- This project uses default configuration — no .env or external ENV variables required.
- Sidekiq requires Redis running on localhost:6379. You can configure this via config/sidekiq.yml or config/initializers/sidekiq.rb if needed.

Clone the repository
git clone https://github.com/your-username/your-repo.git
cd <TARGET DIR>

Install dependencies
```bash
bundle install
```

Set up the database
```bash
rails db:create db:migrate db:seed
```

Start Redis (required for background jobs and request throttling)

If you're using Homebrew (macOS):
```bash
brew install redis
brew services start redis
```

Or with Docker:
```bash
docker run -p 6379:6379 redis
```

Run the server
```bash
rails server
```

in terminal: sidekiq
```bash
bundle exec sidekiq
```

# Gems
- pry - tool for debugging
- redis - for scaling the rate limiter + background jobs
- sidekiq - for background jobs
- kaminari - for pagination
- rspec - testing (requirement)
- factory_bot_rails - dry out test suite

# 1. Rate Limiter
- I considered two approaches for managing request throttling and deduplication:
- Option 1: In-memory Hash: This would store request data in memory, keyed by user ID, and use a Mutex for thread safety. This solution would work for single-server environments but is limited in scalability. It lacks cross-instance coordination, which is problematic in a distributed environment where multiple app instances or servers could be handling requests simultaneously.
- Option 2: Redis-backed solution: Redis offers a distributed cache, ideal for scaling horizontally. By storing request data in Redis, we can share the state across multiple app instances. Redis also provides persistence, ensuring that the rate limiter's data survives app restarts, which is crucial for maintaining request limits over time.
- I opted for Redis because of its ability to scale in distributed environments, providing fault tolerance and persistence across app restarts. This decision ensures the rate limiter can handle high traffic, manage requests efficiently, and maintain consistent state in a multi-instance environment.
- Worth noting rack attack would be a good gem for this...

file path: 
```bash
app/lib/custom_rate_limiter.rb
```

# 2. Job Marketplace API & Optimization
- **Optimized Database Queries:** I implemented eager loading using the includes method to address N+1 query issues. This significantly improved performance when fetching opportunities along with their associated client details. I also used database scopes to encapsulate common query logic, making the code cleaner and more maintainable.
- **Choice of Database:** I chose PostgreSQL for its advanced capabilities, such as full-text search, which is ideal for fast job searching in large datasets. Additionally, PostgreSQL’s efficient query planner helps optimize complex queries, ensuring fast and scalable job search operations.
- **Separation of Concerns:** I moved business logic out of controllers by using service objects, such as OpportunitySearchService and ApplyToOpportunityService. This ensures that controllers remain lean, focused on handling HTTP requests and delegating business logic to services. This improves the maintainability and testability of the code.
- **Testing and Test Data:**** To streamline testing and make it more efficient, I used FactoryBot to standardize the creation of test data. This reduced boilerplate code and improved the readability of the test suite. Each test now easily sets up the necessary objects with less effort, making tests more maintainable.
- **Pagination:**** I integrated the Kaminari gem for pagination, allowing the API to handle large datasets efficiently. This solution allows for dynamic page size configuration and minimizes memory usage, keeping response times optimal even with many records.
- **Logging & Error Handling:** I added structured logging and error handling throughout the app to make debugging easier. With better logs, I can trace issues faster and understand the system's state at any point.
- **Security Considerations:** During development, I temporarily disabled protect_from_forgery to simplify API testing. This will be re-enabled in production to ensure security. Similarly, authentication was skipped for simplicity, but in a production environment, I would implement token-based authentication (e.g., JWT or Devise).

# Where to start?:
- app/controllers/opportunities_controller.rb
- app/lib/result.rb
- app/services/applications/apply_to_opportunity.rb
- app/services/opportunity_search_service.rb
- app/jobs/notify_job_seeker_job.rb
- app/services/notification_service.rb
- app/spec/*, all test can be found here
- db/*
- config/routes.rb
- app/models

**Controller:** The core of the application logic is in the OpportunitiesController, where actions like index, create, and apply reside. The controller is designed to handle HTTP requests and delegate business logic to service objects for clarity and modularity.

**Service Objects:**
- These services help enforce separation of concerns and allow for easier testing and maintenance.
- **ApplyToOpportunityService**encapsulates the logic for a job seeker applying to a job. It helps to keep the controller action clean by offloading application-specific logic.
- **OpportunitySearchService** encapsulates the search and pagination logic from the index action, promoting reusability and improving testability.

- **Result Object:** I implemented the Result object in app/lib/result.rb to standardize success and error responses across the services. This simplifies error handling and improves code consistency.
- **Background Jobs:** The NotifyJobSeekerJob handles notifications for job seekers when their application is processed. Background jobs are processed asynchronously with Sidekiq to avoid - blocking the main application flow.
- **Notification Service:** The NotificationService abstracts the notification logic, allowing easy modifications in the future (e.g., sending emails, SMS, or in-app notifications).
- **Testing & Factories:** I used RSpec for testing, and FactoryBot to create consistent test data. Tests are organized in the app/spec directory, ensuring that all features are covered, from CRUD operations to background jobs.
- **Database & Routes:** Migrations, seeds, and the schema are located in the db folder. Routes are clearly defined in config/routes.rb, making it easy to add new API endpoints as the app grows.
- **Model Optimization:** I kept the models simple and focused on validations and associations, ensuring the app's performance is optimized. Business logic is extracted into services to ensure the models remain lightweight and focused on data handling.

# Running Tests
- Tests for 1. Algo Challenge: Rate Limiter
```bash
 rspec spec/lib/custom_rate_limiter_spec.rb
```

- Tests for 2. Job Marketplace API & Optimization
```bash
  rspec
  or
  rspec spec/<FILE_PATH_TO_TEST>/<TEST_NAME>.spec:<LINE NUMBER>
```

# Curl commands
- I suggest using 3 terminals
- enter curl commands (Terminal 1)
- requires an instance of sidekiq (Terminal 2)
- requires rails server to be running (Terminal 3)
- If test data is needed, I suggest creating additional seeds (db/seeds.rb), then in terminal: rails db:seed 

**Happy Path Testing**
curl -X GET "http://localhost:3000/opportunities?search=Developer&page=1"
curl -X POST "http://localhost:3000/opportunities" \
  -H "Content-Type: application/json" \
  -d '{
    "opportunity": {
      "title": "Software Developer",
      "description": "We are looking for a skilled software developer.",
      "salary": 120000
    }
  }'

curl -X POST "http://localhost:3000/opportunities/1/apply"

**Edge cases Testing**
No search parameters - curl -X GET "http://localhost:3000/opportunities"
Not found - curl -X POST "http://localhost:3000/opportunities/999/apply"
Different Pages - curl -X GET "http://localhost:3000/opportunities?page=2"
Invalid Search Term - curl -X GET "http://localhost:3000/opportunities?search=NonExistentTitle"

curl -X GET "http://localhost:3000/up"

# Known Limitations
- Authentication is stubbed; all users are anonymous.
- No pagination metadata in headers — currently returned in the JSON body.
- CSRF is disabled for development convenience.

# Articles
Separation of Concern - https://en.wikipedia.org/wiki/Separation_of_concerns
On Hashes + block declaration - https://stackoverflow.com/questions/59869743/ruby-hash-new-with-a-block-need-in-depth-explanation
On sliding Window based rate limiter - https://medium.com/%40arpitbhayani/sliding-window-based-rate-limiter-7518ede66474
Shift, array method - https://ruby-doc.org/core-2.5.8/Array.html#method-i-shift
Mutex, thread safety - (Single Server Approach Rate limiting)  
- https://ruby-doc.org/core-2.5.7/Mutex.html
- https://medium.com/@sonianand11/how-to-use-mutex-in-ruby-a-comprehensive-guide-5395db292671

kaminari gem - https://github.com/kaminari/kaminari
ransack gem - https://github.com/activerecord-hackery/ransack
rack attack - https://github.com/rack/rack-attack

**Redis Syntax**
ZREMBRANGEBYSCORE, Removes all elements in the sorted set stored  - https://redis.io/docs/latest/commands/zremrangebyscore/
ZCOUNT, Returns the number of elements in the sorted set - https://redis.io/docs/latest/commands/zcount/
ZAD, Adds all the specified members with the specified scores to the sorted set stored at key - https://redis.io/docs/latest/commands/zadd/
ZRANGE (Score ranges) - https://redis.io/docs/latest/commands/zrange/