require 'test_helper'
require 'action_mailer/test_helper'

class RequestJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  fixtures :checks

  test "that a ping is created on success" do
    check = checks(:default)
    stub_request(:any, "#{check.protocol}://#{check.url}")

    assert_difference 'Ping.count' do
      RequestJob.perform_now(check)
    end
  end

  test "that check is marked uavailable on exceptions (timeouts etc.)" do
    check = checks(:default)
    check.update(available: true)
    stub_request(:any, "#{check.protocol}://#{check.url}").
      to_raise(Exception)

    RequestJob.perform_now(check)

    assert_not(check.available)
  end

  test "that check is marked uavailable when unsuccesful" do
    check = checks(:default)
    stub_request(:any, "#{check.protocol}://#{check.url}").
      to_return(status: 404)

    RequestJob.perform_now(check)

    assert_not(check.available)
  end

  test "that check is marked available on success" do
    check = checks(:default)
    stub_request(:any, "#{check.protocol}://#{check.url}")

    RequestJob.perform_now(check)

    assert(check.available)
  end

  test "that UP alert mail is delivered on positive availability change" do
    check = checks(:default)
    stub_request(:any, "#{check.protocol}://#{check.url}")

    # this helper doesn't work as expected for some reason
    #assert_enqueued_email_with AlertMailer, :up_email do
      RequestJob.perform_now(check)
      assert_enqueued_emails 1
      assert enqueued_jobs.first[:args][0...2] == ["AlertMailer", "up_email"]
    #end
  end

  test "that DOWN alert mail is delivered on negative availability change" do
    check = checks(:default)
    check.update(available: true)
    stub_request(:any, "#{check.protocol}://#{check.url}").
      to_return(status: 404)

    #assert_enqueued_email_with AlertMailer, :down_email do
      RequestJob.perform_now(check)
      assert_enqueued_emails 1
      assert enqueued_jobs.first[:args][0...2] == ["AlertMailer", "down_email"]
    #end
  end
end
