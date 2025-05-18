# frozen_string_literal: true

module NewToNlNavigationItem # rubocop:todo Style/Documentation
  extend ::ActiveSupport::Concern

  included do
    self.route_names = route_names.merge({
                                           partners: 'partners_url',
                                           resources: 'resources_url'
                                         })
  end
end
