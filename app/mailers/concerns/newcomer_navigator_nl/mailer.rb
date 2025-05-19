module NewcomerNavigatorNl
  module Mailer
    extend ActiveSupport::Concern

    included do
      helper ContentHelper
    end
  end
end