class AlertMailer < ApplicationMailer
  include ActionView::Helpers::DateHelper

  def up_email
    @check = params[:check]
    @penultimate, @ultimate = @check.pings.limit(2).order('id desc')

    mail to: default_receiver, subject: "UP alert: #{@check.name} (#{@check.url}) is UP"
  end

  def down_email
    @check = params[:check]
    @reason = params[:reason]
    @last = @check.pings.last

    mail to: default_receiver, subject: "DOWN alert: #{@check.name} (#{@check.url}) is DOWN"
  end
end
