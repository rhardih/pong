class ApplicationMailer < ActionMailer::Base
  default from: ENV['EMAIL_SENDER']
  layout 'mailer'

  def default_receiver
    @default_receiver ||= ENV['EMAIL_RECEIVER']
  end
end
