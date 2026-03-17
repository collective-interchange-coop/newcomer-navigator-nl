# frozen_string_literal: true

require 'uri'

module NewcomerNavigatorNl
  # Ensures controller-generated URLs use the canonical NNNL host.
  module CanonicalUrlOptions
    # Keeps class-level default URL options aligned with the canonical host.
    module ClassMethods
      def default_url_options
        super.merge(NewcomerNavigatorNl::CanonicalUrlOptions.base_url_options)
      end
    end

    def self.prepended(base)
      base.singleton_class.prepend(ClassMethods)
    end

    def default_url_options
      self.class.default_url_options.merge(locale: I18n.locale)
    end

    def self.base_url_options
      uri = URI.parse(BetterTogether.base_url)
      options = {
        host: uri.host,
        protocol: uri.scheme
      }
      options[:port] = uri.port if uri.port && uri.port != uri.default_port
      options
    end
  end
end
