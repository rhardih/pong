class QueueRequestJobs
  def self.perform
    Check.stale.each { |c| RequestJob.perform_later(c) }
  end
end
