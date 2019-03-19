require 'test_helper'

class QueueRequestJobsTest < ActiveJob::TestCase
  fixtures :checks

  test "enqueues" do
    QueueRequestJobs.perform

    assert_enqueued_jobs Check.stale.count + Check.limbo.count + Check.down.count
  end
end
