require 'benchmark'
require 'net/http'

class RequestJob < ApplicationJob
  queue_as :default

  def perform(check)
    uri = URI("#{check.protocol}://#{check.url}")
    time = Benchmark.measure { Net::HTTP.get(uri) }
    check.pings.create!(response_time: time.real * 1000)
  end
end
