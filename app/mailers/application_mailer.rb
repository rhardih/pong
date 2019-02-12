class ApplicationMailer < ActionMailer::Base
  layout 'mailer'

  def default_receiver
    @default_receiver ||= ENV['EMAIL_RECEIVER']
  end
end
