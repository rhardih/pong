require 'benchmark'
require 'net/http'

class RequestJob < ApplicationJob
  queue_as :default

  def perform(check)
    uri = URI("#{check.protocol}://#{check.url}")
    req = Net::HTTP::Head.new(uri.request_uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.read_timeout = 5
    http.open_timeout = 5
    res = nil

    time = Benchmark.measure { res = http.request(req) }

    case res
    when Net::HTTPSuccess
      success(check, time.real * 1000)
    else
      failure(check, "#{res.code} - #{res.message}")
    end

  rescue Exception => e
    logger.error(e)

    failure(check, e.message)
  end

  def success(check, response_time)
    check.pings.create!(response_time: response_time)
    check.update!(retries: 0)

    unless check.up?
      notify_up(check)
      check.up!
    end
  end

  def failure(check, reason)
    if check.up?
      check.limbo!
    elsif check.limbo?
      if check.retries > Pong.retry_max
        check.down!
        check.update!(retries: 0)
        notify_down(check, reason)
      else
        check.update!(retries: check.retries + 1)
      end
    end
  end

  def notify_up(check)
    AlertMailer.with(check: check).up_email.deliver_later

    if Pong.telegram_enabled?
      TelegramNotificationJob.perform_later(check, up: true)
    end
  end

  def notify_down(check, reason)
    AlertMailer.with(check: check, reason: reason).down_email.deliver_later

    if Pong.telegram_enabled?
      TelegramNotificationJob.perform_later(check, up: false, reason: reason)
    end
  end
end
