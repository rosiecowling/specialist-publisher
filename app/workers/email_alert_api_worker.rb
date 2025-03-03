require "services"

class EmailAlertApiWorker
  include Sidekiq::Worker

  def perform(payload)
    begin
      GdsApi.email_alert_api.create_content_change(payload)
    rescue GdsApi::HTTPConflict
      logger.info("email-alert-api returned 409 conflict for #{payload}")
    end
  end
end
