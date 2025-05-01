require "spec_helper"
require "pry"
require_relative '../../app/lib/custom_rate_limiter'

RSpec.describe CustomRateLimiter do
  before do
    @redis = Redis.new(url: "redis://localhost:6379/0")
    @redis.flushdb
    @time_window = 30 # seconds
    @max_requests = 3
    @rate_limiter = CustomRateLimiter.new(@time_window, @max_requests)
  end

  describe "#allow_request?" do
    context "when the request is within the limit" do
      it "allows the first request" do
        expect(@rate_limiter.allow_request?(1700000010, 1)).to be(true)
      end

      it "allows the second request" do
        expect(@rate_limiter.allow_request?(1700000011, 1)).to be(true)
      end

      it "allows the third request" do
        expect(@rate_limiter.allow_request?(1700000020, 1)).to be(true)
      end
    end

    context "when the request exceeds the limit" do
      before do
        @rate_limiter.allow_request?(1700000010, 1)
        @rate_limiter.allow_request?(1700000011, 1)
        @rate_limiter.allow_request?(1700000020, 1)
      end

      it "blocks the fourth request" do
        expect(@rate_limiter.allow_request?(1700000030, 1)).to be(false)
      end
    end

    context "when the time window has expired" do
      before do
        @rate_limiter.allow_request?(1700000010, 1)
        @rate_limiter.allow_request?(1700000011, 1)
        @rate_limiter.allow_request?(1700000020, 1)
      end

      it "allows a request after the time window expires" do
        expect(@rate_limiter.allow_request?(1700000041, 1)).to be(true)
      end
    end

    context "when there are multiple users" do
      it "allows requests for different users independently" do
        expect(@rate_limiter.allow_request?(1700000010, 1)).to be(true) # User 1, first request
        expect(@rate_limiter.allow_request?(1700000011, 2)).to be(true) # User 2, first request
        expect(@rate_limiter.allow_request?(1700000020, 1)).to be(true) # User 1, second request
        expect(@rate_limiter.allow_request?(1700000021, 2)).to be(true) # User 2, second request
      end
    end

    context "when there are multiple requests within the time window" do
      it "allows multiple requests within the time window for the same user" do
        expect(@rate_limiter.allow_request?(1700000010, 1)).to be(true) # User 1, first request
        expect(@rate_limiter.allow_request?(1700000011, 1)).to be(true) # User 1, second request
        expect(@rate_limiter.allow_request?(1700000015, 1)).to be(true) # User 1, third request
      end
    end
  end

  describe "Stress testing rate limiter" do
    it "should allow requests within the limit and block requests over the limit for a single user" do
      user_id = 1

      timestamp = 1700000000 # large number of requests, small time window
      3.times do |i|
        expect(@rate_limiter.allow_request?(timestamp + i, user_id)).to be(true)
      end

      expect(@rate_limiter.allow_request?(timestamp + 3, user_id)).to be(false)  # 4th request should be blocked
    end

    it "should correctly handle requests from multiple users" do
      user_id_1 = 1
      user_id_2 = 2
      timestamp = 1700000000

      expect(@rate_limiter.allow_request?(timestamp, user_id_1)).to be(true)  # First request for user 1 (allowed)
      expect(@rate_limiter.allow_request?(timestamp + 1, user_id_2)).to be(true)  # First request for user 2 (allowed)
      expect(@rate_limiter.allow_request?(timestamp + 2, user_id_1)).to be(true)  # Second request for user 1 (allowed)
      expect(@rate_limiter.allow_request?(timestamp + 3, user_id_2)).to be(true)  # Second request for user 2 (allowed)

      expect(@rate_limiter.allow_request?(timestamp + 4, user_id_1)).to be(true)  # Third request for user 1 (allowed)
      expect(@rate_limiter.allow_request?(timestamp + 4, user_id_2)).to be(true)  # Third request for user 2 (allowed)

      # The 4th request should be blocked for both users
      expect(@rate_limiter.allow_request?(timestamp + 5, user_id_1)).to be(false)  # Fourth request for user 1 (blocked)
      expect(@rate_limiter.allow_request?(timestamp + 5, user_id_2)).to be(false)  # Fourth request for user 2 (blocked)
    end

    it "should allow requests to reset after time window expires" do
      user_id = 1
      timestamp = 1700000000

      3.times do |i| # First three requests
        expect(@rate_limiter.allow_request?(timestamp + i, user_id)).to be(true)
      end

      expect(@rate_limiter.allow_request?(timestamp + 3, user_id)).to be(false) # Fourth request should be blocked

      # Simulate time window expiry (wait for 31 seconds)
      expect(@rate_limiter.allow_request?(timestamp + 31, user_id)).to be(true)  # Should be allowed again
    end

    it "stress test, should never allow more than 3 requests in a 30-second window" do
      user_id = 1
      timestamp = 1700000000
      allowed_timestamps = []

      1000.times do |i|
        ts = timestamp + i
        allowed = @rate_limiter.allow_request?(ts, user_id)

        window_start = ts - @time_window

        allowed_timestamps.reject! { |t| t < window_start } # Remove old entries

        if allowed
          allowed_timestamps << ts
        end

        expect(allowed_timestamps.size).to be <= @max_requests
      end
    end
    it "should handle simultaneous requests for multiple users" do
      user_ids = (1..100).to_a
      timestamp = 1700000000

      # Simulate 100 users sending requests at the same time (or within the same window)
      user_ids.each do |user_id|
        expect(@rate_limiter.allow_request?(timestamp, user_id)).to be(true)
      end
    end
  end
end
