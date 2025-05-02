class JobSeeker < ApplicationRecord
  has_many :job_applications
  has_many :opportunities, through: :job_applications

  validates :name, presence: true
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
