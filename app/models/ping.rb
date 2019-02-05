class Ping < ApplicationRecord
  belongs_to :check

  validates :response_time, presence: true, allow_nil: false
end
