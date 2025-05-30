# frozen_string_literal: true

Rails.application.config.to_prepare do
  require_dependency 'better_together/application_controller'
  require_dependency 'better_together/host_dashboard_controller'

  BetterTogether::ApplicationController.include(NewcomerNavigatorNl::ControllerErrorReporting)
  BetterTogether::HostDashboardController.include(NewToNlHostDashboard)
end
