check = Check.create(name: 'Example', interval: 1, protocol: 'https', url: 'example.com')

# Create pings for the last seven days
date = 7.days.ago.beginning_of_day
# response time
#rt = 250
now = Time.now

spike = lambda do |rt, &block|
  # 10% chance of a spike
  rt += rand(150..250) if rand(0..9) < 1

  block.call(rt)
end

while date < now
  spike.call(250 + rand(-25..25)) do |rt|
    Ping.create(check: check, response_time: rt, created_at: date)
  end

  date = date.advance(minutes: 1)
end
