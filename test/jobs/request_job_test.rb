require 'test_helper'
require 'action_mailer/test_helper'

class RequestJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  fixtures :checks

  test "that a ping is created on success" do
    check = checks(:up)
    stub_request(:any, "#{check.protocol}://#{check.url}")

    assert_difference 'Ping.count' do
      RequestJob.perform_now(check)
    end
  end

  test "that the check is put in limbo on exceptions (timeouts etc.)" do
    check = checks(:up)
    stub_request(:any, "#{check.protocol}://#{check.url}").
      to_raise(Exception)

    RequestJob.perform_now(check)

    assert(check.limbo?)
  end

  test "that check is put in limbo when request is unsuccesful" do
    check = checks(:up)
    stub_request(:any, "#{check.protocol}://#{check.url}").
      to_return(status: 404)

    RequestJob.perform_now(check)

    assert(check.limbo?)
  end

  test "that number of retries is incremented when request is unsuccesful" do
    check = checks(:limbo)
    stub_request(:any, "#{check.protocol}://#{check.url}").
      to_return(status: 404)

    assert_difference 'check.retries', 1 do
      RequestJob.perform_now(check)
    end
  end

  test "that check is marked as down when retry limit has been reached" do
    check = checks(:limbo)
    check.retries = Pong.retry_max + 1
    stub_request(:any, "#{check.protocol}://#{check.url}").
      to_return(status: 404)

    RequestJob.perform_now(check)

    assert(check.down?)
  end

  test "that check is marked as up on successful request" do
    check = checks(:down)
    stub_request(:any, "#{check.protocol}://#{check.url}")

    RequestJob.perform_now(check)

    assert(check.up?)
  end

  test "that UP alert mail is delivered when check comes back up" do
    check = checks(:down)
    stub_request(:any, "#{check.protocol}://#{check.url}")

    # this helper doesn't work as expected for some reason
    #assert_enqueued_email_with AlertMailer, :up_email do
      RequestJob.perform_now(check)
      assert_enqueued_emails 1
      assert enqueued_jobs.first[:args][0...2] == ["AlertMailer", "up_email"]
    #end
  end

  test "that DOWN alert mail is delivered when check goes down" do
    check = checks(:limbo)
    check.retries = Pong.retry_max + 1
    stub_request(:any, "#{check.protocol}://#{check.url}").
      to_return(status: 404)

    #assert_enqueued_email_with AlertMailer, :down_email do
      RequestJob.perform_now(check)
      assert_enqueued_emails 1
      assert enqueued_jobs.first[:args][0...2] == ["AlertMailer", "down_email"]
    #end
  end

  test "that Telegram notification is delivered when check comes back up" do
    check = checks(:down)
    stub_request(:any, "#{check.protocol}://#{check.url}")

    Pong.stub(:telegram_enabled?, true) do
      assert_enqueued_with(job: TelegramNotificationJob, args: [check, up: true]) do
        RequestJob.perform_now(check)
      end
    end
  end

  test "that Telegram notification is delivered when check goes down" do
    check = checks(:limbo)
    check.retries = Pong.retry_max + 1
    stub_request(:any, "#{check.protocol}://#{check.url}").
      to_return(status: 404)

    Pong.stub(:telegram_enabled?, true) do
      assert_enqueued_with(job: TelegramNotificationJob, args: [check, up: false]) do
        RequestJob.perform_now(check)
      end
    end
  end
end
