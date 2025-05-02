class Client < ApplicationRecord
  has_many :opportunities, dependent: :destroy

  validates_presence_of :name
end
