require 'erb'
require 'ostruct'
require 'telegram/bot'

class TelegramNotificationJob < ApplicationJob
  queue_as :default

  def perform(check, available:)
    key = ENV['TELEGRAM_API_KEY']
    mid = ENV['TELEGRAM_CHAT_ID']

    penultimate, ultimate = check.pings.limit(2).order('id desc')

    # Re-use the mailer views for convenience
    if available
      message = ApplicationController.renderer.render({
        template: 'alert_mailer/up_email.text',
        locals: {
          :@check => check,
          :@penultimate => penultimate,
          :@ultimate => ultimate
        }
      })
    else
      message = ApplicationController.renderer.render({
        template: 'alert_mailer/down_email.text',
        locals: { :@check => check }
      })
    end

    Telegram::Bot::Client.run(key) do |bot|
      bot.api.send_message(chat_id: mid, text: message)
    end
  end
end
