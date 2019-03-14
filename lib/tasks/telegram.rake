require 'telegram/bot'

namespace :telegram do
  desc "Starts the telegram bot, which will show the chat id needed for setup."
  task run: :environment do
    unless ENV.key?('TELEGRAM_API_KEY')
      puts "Environment variable TELEGRAM_API_KEY needs to be set before running this task. Quitting."
      return
    end

    Telegram::Bot::Client.run(ENV['TELEGRAM_API_KEY']) do |bot|
      bot.listen do |message|
        case message.text
        when '/start'
          bot.api.send_message({
            chat_id: message.chat.id,
            text: "Hi here,\n\nHere is your chat id:\n\nTELEGRAM_CHAT_ID=#{message.chat.id}"
          })
          exit
        end
      end
    end
  end
end
