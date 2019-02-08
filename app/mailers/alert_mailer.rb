class AlertMailer < ApplicationMailer
  def up_email
    @greeting = "Hi"
    @check = params[:check]

    mail to: default_receiver, subject: "UP alert: #{@check.name} (#{@check.url}) is UP"
  end

  def down_email
    @greeting = "Hi"
    @check = params[:check]

    mail to: default_receiver, subject: "DOWN alert: #{@check.name} (#{@check.url}) is DOWN"
  end
end
