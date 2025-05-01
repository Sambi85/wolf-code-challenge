require "redis"

class CustomRateLimiter
  def initialize(time_window, max_requests)
    @time_window = time_window
    @max_requests = max_requests
    @redis = Redis.new(url: "redis://localhost:6379/0")
  end

  def allow_request?(timestamp, user_id)
    begin
      key = "rate_limiter:#{user_id}"

      window_start = timestamp - @time_window # sliding window

      @redis.zremrangebyscore(key, "(-inf", "(#{window_start}")  # remove expired entries

      request_count = @redis.zcount(key, window_start, timestamp) # count requests in time window

      if request_count < @max_requests
        @redis.zadd(key, timestamp, timestamp) # add current timestamp
        @redis.expire(key, @time_window) # update expiration with current time window

        puts "[INFO][REDIS] - Request allowed for user #{user_id} at #{timestamp}. Current count: #{request_count + 1}"

        true
      else

        puts "[INFO][REDIS] - Request blocked for user #{user_id} at #{timestamp}. Exceeded max requests."

        false
      end
    rescue Redis::BaseError => e
      puts "[ERROR][REDIS] - Error while processing request: #{e.message}"
      false
    end
  end
end
