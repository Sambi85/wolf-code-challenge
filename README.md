# README - Wolf Api + Rate Limiter Challenge

# Important:
- added both tasks to this repo

# Setup:
- git clone this repo to your local
- navigate to the root dir of this project

in terminal: rails s
bundle install
rails s

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
file path: 
```bash
app/lib/custom_rate_limiter.rb
```

- I see 2 approaches here
- option 1: use a hash to hold timestamps based on user id + mutex to guard againist thread safety (single server)
- option 2: use redis for request queue (multiple app instances, encapsulation of data between instances, better for high traffic)
- I went with Redis for scaling, fault tolerance, and maintainability.

# 2. Job Marketplace API & Optimization
- Added scopes to optimize db queries 
- Using Postgres, it's a good fit for optimizations for queries
- Added services to clean up controllers + seperate concerns
- Added Factories for drying out tests + making test management easier overall
- Using a gem for pagination. Make sense in this context, easier to manage
- Disabled protect_from_forgery for this assessment, I would in a production enviroment
- Did not implement Auth for this assessment, I would in a production environment
- Added logging + error handling when needed

Services + Helpers:
- app/lib/result.rb is a helper class. 
- app/services/applications/apply_to_opportunity.rb is a service

# Running Tests
- Test for 1. Algo Challenge: Rate Limiter
```bash
 rspec spec/lib/custom_rate_limiter_spec.rb
```

- Test for 2.Job Marketplace API & Optimization
```bash
  rspec
  or
  rspec spec/
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