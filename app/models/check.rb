class Check < ApplicationRecord
  has_many :pings, dependent: :delete_all

  scope :stale, -> do
    clauses = [
      "pings.created_at < now() - checks.interval * interval '1 min'",
      "pings.id IS NULL"
    ]
    left_joins(:pings).where(clauses.join(" OR ")).distinct
  end

  def self.protocols
    ["https", "http"]
  end

  validates :name, presence: true
  validates :interval, numericality: { only_integer: true }
  validates :protocol, inclusion: { in: protocols }
  validates :url, presence: true
end
