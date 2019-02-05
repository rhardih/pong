require 'test_helper'

class CheckTest < ActiveSupport::TestCase
  fixtures :checks
  fixtures :pings

  test "stale" do
    stale = Check.stale

    # default has no pings
    assert_includes(stale, checks(:default))
    # expired has one ping, but too old
    assert_includes(stale, checks(:expired))
    # expired has one ping, up to date
    assert_not_includes(stale, checks(:fresh))
  end
end
