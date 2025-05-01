class CustomRateLimiter
  def initialize(time_window, max_requests)
    @time_window = time_window
    @max_requests = max_requests
    @requests = Hash.new { |h, k| h[k] = [] } # key: user_id, value: an array of timestamps
  end

  def allow_request?(timestamp, user_id)
    queue = @requests[user_id]

    while queue.any? && (timestamp - queue.first) >= @time_window # Remove old requests (time window)
      queue.shift
    end

    if queue.size < @max_requests # guard queue size
      queue << timestamp
      true
    else
      false
    end
  end
end
