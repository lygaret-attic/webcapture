require File.expand_path("../boot", __FILE__)

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

module Webcapture
  class Application < Rails::Application

    # setup application configuration
    config.x.auth = Rails.application.config_for(:auth)

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Authenticate Twilio Webhooks
    auth_token = Rails.application.secrets.twilio_auth_token
    config.middleware.use Rack::TwilioWebhookAuthentication, auth_token, /twilio-hook/
  end
end
