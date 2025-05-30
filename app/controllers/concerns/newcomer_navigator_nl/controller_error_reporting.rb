# frozen_string_literal: true

module NewcomerNavigatorNl
  # Extends BetterTogether::Geography::Map
  module ControllerErrorReporting
    extend ActiveSupport::Concern

    included do
      def error_reporting(exception)
        # Send exception to Sentry
        Rails.logger.error(exception.message)
        Sentry.capture_exception(exception)
      end
    end
  end
end
