class Ping < ApplicationRecord
  belongs_to :check

  validates :response_time, presence: true, allow_nil: false

  def self.percentile_for(check, p)
    q = %Q{
      SELECT percentile_cont(#{p}) within group (order by response_time asc)
      FROM "pings"
      WHERE "pings"."check_id" = #{check.id}
    }
    ActiveRecord::Base.connection.exec_query(q).first.to_hash["percentile_cont"]
  end
end
