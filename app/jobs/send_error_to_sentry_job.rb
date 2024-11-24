# frozen_string_literal: true

class SendErrorToSentryJob < ApplicationJob
  queue_as :default

  def perform(exception)
    Sentry.capture_exception(exception)
  end
end
