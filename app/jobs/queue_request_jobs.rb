class QueueRequestJobs
  def self.perform
    # The stale scope isn't structurally compatible, so is explicitly not
    # chained here
    Check.stale.each { |c| RequestJob.perform_later(c) }

    # For hosts that are down or in limbo, a check is performed every minute and
    # the value of <interval> is disregarded
    Check.limbo.or(Check.down).each { |c| RequestJob.perform_later(c) }
  end
end
