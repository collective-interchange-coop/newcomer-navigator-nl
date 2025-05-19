# frozen_string_literal: true

ActiveSupport::Reloader.to_prepare do
  require_dependency 'better_together/application_mailer'

  BetterTogether::ApplicationMailer.include(NewcomerNavigatorNl::Mailer)
end
