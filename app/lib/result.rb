class Result
  attr_reader :value, :errors

  def initialize(success:, value: nil, errors: [])
    @success = success
    @value = value
    @errors = errors
  end

  def self.success(value = nil) = new(success: true, value: value)
  def self.failure(errors = []) = new(success: false, errors: Array(errors))

  def success? = @success
  def failure? = !@success
end
