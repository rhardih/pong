require 'test_helper'

class QueueRequestJobsTest < ActiveJob::TestCase
  fixtures :checks

  test "enqueus request jobs" do
    assert_enqueued_with(job: RequestJob, args: [checks(:default)]) do
      assert_enqueued_with(job: RequestJob, args: [checks(:expired)]) do
        QueueRequestJobs.perform
      end
    end
  end
end
