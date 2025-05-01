# README - Wolf Api + Rate Limiter Challenge

# Important:
- added both tasks to this repo

# Setup:
- wip


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
- wip


# Running Tests
- Test for 1. Algo Challenge: Rate Limiter
```bash
 rspec spec/lib/custom_rate_limiter_spec.rb
```

- Test for 2.Job Marketplace API & Optimization
```bash
  wip
```

# Articles
On Hashes + block declaration - https://stackoverflow.com/questions/59869743/ruby-hash-new-with-a-block-need-in-depth-explanation
On sliding Window based rate limiter - https://medium.com/%40arpitbhayani/sliding-window-based-rate-limiter-7518ede66474
Shift, array method - https://ruby-doc.org/core-2.5.8/Array.html#method-i-shift
Mutex, thread safety - (Single Server Approach Rate limiting)  
- https://ruby-doc.org/core-2.5.7/Mutex.html
- https://medium.com/@sonianand11/how-to-use-mutex-in-ruby-a-comprehensive-guide-5395db292671

**Redis Syntax**
ZREMBRANGEBYSCORE, Removes all elements in the sorted set stored  - https://redis.io/docs/latest/commands/zremrangebyscore/
ZCOUNT, Returns the number of elements in the sorted set - https://redis.io/docs/latest/commands/zcount/
ZAD, Adds all the specified members with the specified scores to the sorted set stored at key - https://redis.io/docs/latest/commands/zadd/
ZRANGE (Score ranges) - https://redis.io/docs/latest/commands/zrange/