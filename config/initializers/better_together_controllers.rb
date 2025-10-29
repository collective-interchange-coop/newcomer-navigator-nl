# frozen_string_literal: true

Rails.application.config.to_prepare do
  require 'better_together/application_controller'
  require 'better_together/host_dashboard_controller'
  require 'better_together/users/registrations_controller'

  BetterTogether::ApplicationController.include(NewcomerNavigatorNl::ControllerErrorReporting)
  BetterTogether::HostDashboardController.include(NewToNlHostDashboard)
  BetterTogether::Users::RegistrationsController.include(NewToNlCaptchaValidation)
end
