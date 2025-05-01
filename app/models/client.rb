class Client < ApplicationRecord
  has_many :opportunities, dependent: :destroy
end
