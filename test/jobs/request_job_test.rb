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
    [:down, :limbo].each do |s|
      check = checks(s)
      stub_request(:any, "#{check.protocol}://#{check.url}")

      RequestJob.perform_now(check)

      assert(check.up?)
    end
  end

  test "that UP alert mail is delivered when check comes back up" do
    check = checks(:down)
    stub_request(:any, "#{check.protocol}://#{check.url}")

    # this helper doesn't work as expected for some reason
    #assert_enqueued_email_with AlertMailer, :up_email do
      RequestJob.perform_now(check)
      assert enqueued_jobs.first[:args][0...2] == ["AlertMailer", "up_email"]
    #end
  end

  test "that there's no alert mail when check comes back up from limbo" do
    check = checks(:limbo)
    stub_request(:any, "#{check.protocol}://#{check.url}")

    RequestJob.perform_now(check)
    assert_no_enqueued_jobs
  end

  test "that DOWN alert mail is delivered when check goes down" do
    check = checks(:limbo)
    check.retries = Pong.retry_max + 1
    stub_request(:any, "#{check.protocol}://#{check.url}").
      to_return(status: 404)

    #assert_enqueued_email_with AlertMailer, :down_email do
      RequestJob.perform_now(check)
      assert enqueued_jobs.first[:args][0...2] == ["AlertMailer", "down_email"]
    #end
  end

  test "that DOWN alert mail is delivered when check times out" do
    check = checks(:limbo)
    check.retries = Pong.retry_max + 1
    stub_request(:any, "#{check.protocol}://#{check.url}").to_timeout

    RequestJob.perform_now(check)

    assert enqueued_jobs.first[:args][0...2] == ["AlertMailer", "down_email"]

    actual_job_hash = enqueued_jobs.first[:args][3]
    expected_job_hash = {
      "check" => { "_aj_globalid" => check.to_global_id.to_s },
      "reason" => "execution expired"
    }

    # hash comparison, meaning keys and values of expected is included in actual
    assert actual_job_hash >= expected_job_hash
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
      to_return(status: [404, "Eh, nothing here bud"])

    Pong.stub(:telegram_enabled?, true) do
      args = [check, {
        up: false,
        reason: "404 - Eh, nothing here bud"
      }]

      assert_enqueued_with(job: TelegramNotificationJob, args: args) do
        RequestJob.perform_now(check)
      end
    end
  end
end
