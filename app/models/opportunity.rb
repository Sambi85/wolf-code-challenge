class Opportunity < ApplicationRecord
  belongs_to :client
  has_many :job_applications, dependent: :destroy

  validates :title, :description, :salary, presence: true
  validates :salary, numericality: { greater_than_or_equal_to: 0 }

  # Scopes for searching and optimizing queries
  scope :search_by_title, ->(title) { where("title ILIKE ?", "%#{title}%") }
  scope :with_client_name, -> { joins(:client).includes(:client).select("opportunities.*, clients.name AS client_name") }
end
