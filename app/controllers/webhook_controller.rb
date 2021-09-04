class WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token,except: :stripe_webhook

  def stripe_webhook

  end
end