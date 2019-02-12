require 'test_helper'

class AlertMailerTest < ActionMailer::TestCase
  fixtures :checks

  test "up_email" do
    check = checks(:default)
    email = AlertMailer.with(check: check).down_email
 
    assert_emails(1) { email.deliver_now }
 
    assert_equal ['test@example.com'], email.from
    assert_equal [ENV['EMAIL_RECEIVER']], email.to
    assert_equal "DOWN alert: #{check.name} (#{check.url}) is DOWN", email.subject
  end
end
