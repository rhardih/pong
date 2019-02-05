require 'test_helper'

class QueueRequestJobsTest < ActiveJob::TestCase
  fixtures :checks

  test "only enqueues jobs for stale checks" do
    # one for both Default and Expired checks
    assert_enqueued_jobs 2 do
      QueueRequestJobs.perform
    end
  end

  test "enqueus request jobs" do
    assert_enqueued_with(job: RequestJob, args: [checks(:default)]) do
      assert_enqueued_with(job: RequestJob, args: [checks(:expired)]) do
        QueueRequestJobs.perform
      end
    end
  end
end
