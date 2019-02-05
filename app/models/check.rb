class Check < ApplicationRecord
  def self.protocols
    ["https", "http"]
  end

  validates :name, presence: true
  validates :interval, numericality: { only_integer: true }
  validates :protocol, inclusion: { in: protocols }
  validates :url, presence: true
end
