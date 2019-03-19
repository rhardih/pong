require 'test_helper'

class TelegramNotificationJobTest < ActiveJob::TestCase
  fixtures :checks

  def setup
    ENV['TELEGRAM_API_KEY'] = 'foo'
    ENV['TELEGRAM_CHAT_ID'] = 'bar'
  end

  test "perform up notification" do
    check = checks(:up)
    ts = check.pings.first.created_at

    stub_request(:post, "https://api.telegram.org/botfoo/sendMessage").with(
      body: {
        chat_id: "bar",
        text: "Pong Alert\n\nUp is up again at #{ts}, after 5 minutes of downtime.\n"
      }).to_return(status: 200, body: "{}")

    TelegramNotificationJob.perform_now(check, up: true)

    assert_requested :post, "https://api.telegram.org/botfoo/sendMessage"
  end

  test "perform down notification" do
    check = checks(:up)
    ts = check.pings.first.created_at

    stub_request(:post, "https://api.telegram.org/botfoo/sendMessage").with(
      body: {
        chat_id: "bar",
        text: "Pong Alert\n\nUp is down.\n"
      }).to_return(status: 200, body: "{}")

    TelegramNotificationJob.perform_now(check, up: false)

    assert_requested :post, "https://api.telegram.org/botfoo/sendMessage"
  end
end
