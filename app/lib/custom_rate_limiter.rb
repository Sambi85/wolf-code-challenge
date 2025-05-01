require "redis"

class CustomRateLimiter
  def initialize(time_window, max_requests)
    @time_window = time_window
    @max_requests = max_requests
    @redis = Redis.new(url: "redis://localhost:6379/0") # Connect to Redis
  end

  def allow_request?(timestamp, user_id)
    key = "rate_limiter:#{user_id}"

    window_start = timestamp - @time_window # define sliding window here

    @redis.zremrangebyscore(key, "(-inf", "(#{window_start}")  # remove expired entries (what's outside the time window)

    request_count = @redis.zcount(key, window_start, timestamp) # count requests within the time window

    if request_count < @max_requests
      @redis.zadd(key, timestamp, timestamp) # add current request timestamp
      @redis.expire(key, @time_window) # update expiration with current time window
      true
    else
      false
    end
  end
end
