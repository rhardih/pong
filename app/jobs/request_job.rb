require 'benchmark'
require 'net/http'

class RequestJob < ApplicationJob
  queue_as :default

  def update_availability(check, value)
    if (check.available != value)
      if (value)
        AlertMailer.with(check: check).up_email.deliver_later
      else
        AlertMailer.with(check: check).down_email.deliver_later
      end
    end

    check.update(available: value)
  end

  def perform(check)
    uri = URI("#{check.protocol}://#{check.url}")
    req = Net::HTTP::Head.new(uri.request_uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.read_timeout = 5
    http.open_timeout = 5
    res = nil

    time = Benchmark.measure do
      res = http.request(req)
    end

    case res
    when Net::HTTPSuccess
      check.pings.create!(response_time: time.real * 1000)
      update_availability(check, true)
    else
      update_availability(check, false)
    end

  rescue Exception => e
    #logger.error(e)

    update_availability(check, false)
  end
end
