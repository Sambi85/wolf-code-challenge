# README - Wolf Api + Rate Limiter Challenge

# Important:
- please note, both assigned tasks can be found this repo

🛠 Setup
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
- redis - for scaling the rate limiter
- sidekiq - for background jobs
- kaminari - for pagination
- rspec - testing (requirement)
- factory_bot_rails - dry out test suite

# 1. Rate Limiter
- considered two approaches for managing request throttling or deduplication:
- option 1: In-memory Hash keyed by user ID with a Mutex for thread safety — sufficient for single-server environments but lacks cross-instance coordination.
- option 2: Redis-backed solution to track request state — supports distributed environments, scales better under load, and provides persistence across app restarts.
- chose Redis for its scalability, fault tolerance, and ability to encapsulate shared state across multiple application instances, making it the better long-term solution.

file path: 
```bash
app/lib/custom_rate_limiter.rb
```

# 2. Job Marketplace API & Optimization
- implemented database scopes and eager loading (includes) to eliminate N+1 query issues and improve performance.
- chose PostgreSQL for its robust support of text search and efficient query planning—well-suited for scalable search operations.
- extracted business logic into dedicated service objects to enforce separation of concerns and keep controllers lean.
- used FactoryBot to standardize and simplify test setup, improving test readability and maintainability.
- integrated a pagination gem (kaminari or will_paginate) to manage large datasets efficiently and simplify paging logic.
- added structured logging and error handling to make debugging easier and improve observability.
- temporarily disabled protect_from_forgery for API testing convenience; would re-enable and secure CSRF handling in production.
- authentication was not implemented in this assessment for simplicity, but would be integrated using token-based auth (e.g., JWT or Devise) in a production environment.

# Services + Helpers:
- app/lib/result.rb provides a simple, consistent result object for service responses — helps enforce separation of concerns and simplifies success/error handling across the app.
- app/services/applications/apply_to_opportunity.rb encapsulates application logic for job seekers, keeping the OpportunitiesController#apply action clean and focused.
- app/services/opportunity_search_service.rb extracts search and pagination logic from the #index action, promoting reuse and improving testability.
- app/jobs/notify_job_seeker_job.rb, handles background job
- app/services/notification_service.rb, notification

# Running Tests
- Tests for 1. Algo Challenge: Rate Limiter
```bash
 rspec spec/lib/custom_rate_limiter_spec.rb
```

- Tests for 2. Job Marketplace API & Optimization
```bash
  rspec
  or
  rspec spec/<FILE_PATH_TO_TEST>/test.spec:<LINE NUMBER>
```

# Curl commands
- I suggest using 3 terminals
- enter curl commands (Terminal 1)
- requires an instance of sidekiq (Terminal 2)
- requieres rails server to be running (Terminal 3)

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

**Redis Syntax**
ZREMBRANGEBYSCORE, Removes all elements in the sorted set stored  - https://redis.io/docs/latest/commands/zremrangebyscore/
ZCOUNT, Returns the number of elements in the sorted set - https://redis.io/docs/latest/commands/zcount/
ZAD, Adds all the specified members with the specified scores to the sorted set stored at key - https://redis.io/docs/latest/commands/zadd/
ZRANGE (Score ranges) - https://redis.io/docs/latest/commands/zrange/