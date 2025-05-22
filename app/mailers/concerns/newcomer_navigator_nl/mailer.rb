# frozen_string_literal: true

module NewcomerNavigatorNl
  # Additional helper methods for mailer views
  module Mailer
    extend ActiveSupport::Concern

    included do
      helper ContentHelper
    end
  end
end
