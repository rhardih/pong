require 'test_helper'

class RequestJobTest < ActiveJob::TestCase
  fixtures :checks

  test "that a ping is created" do
    check = checks(:default)

    assert_difference 'Ping.count' do
      RequestJob.perform_now(check)
    end
  end
end
