require 'test_helper'

class CheckTest < ActiveSupport::TestCase
  fixtures :checks
  fixtures :pings

  test "stale" do
    stale = Check.stale

    # up has no pings
    assert_includes(stale, checks(:up))
    # expired has one ping, but too old
    assert_includes(stale, checks(:expired))
    # expired has one ping, up to date
    assert_not_includes(stale, checks(:fresh))
    # all are up
    assert(stale.all?(&:up?))
  end
end
