# frozen_string_literal: true

require 'uri'

module NewcomerNavigatorNl
  # Shared helpers for rewriting absolute URLs onto the canonical NNNL host.
  module CanonicalUrlHelper
    TRANSPORT_HOST_ALIASES = %w[
      bts-5-zt.btsdev.ca
      bts-5-cf.btsdev.ca
      nnnl-prod-zt.btsdev.ca
      nnnl-prod-cf.btsdev.ca
      test.newcomernavigatornl.ca
      newcomernavigatornl.ca
    ].freeze

    private

    def canonical_url_options
      NewcomerNavigatorNl::CanonicalUrlOptions.base_url_options
    end

    def canonical_base_url
      @canonical_base_url ||= BetterTogether.base_url.to_s.chomp('/')
    end

    def canonical_absolute_url(value)
      return canonical_base_url if value.blank?

      string = value.to_s
      return "#{canonical_base_url}#{string}" if string.start_with?('/')

      rewrite_absolute_url(string)
    rescue URI::InvalidURIError
      "#{canonical_base_url}/#{string.sub(%r{\A/+}, '')}"
    end

    def rewrite_absolute_url(string)
      uri = URI.parse(string)
      return string unless canonicalizable_origin_host?(uri.host)

      uri.scheme = canonical_url_options[:protocol]
      uri.host = canonical_url_options[:host]
      uri.port = canonical_url_options[:port]
      uri.to_s
    end

    def canonicalizable_origin_host?(host)
      TRANSPORT_HOST_ALIASES.include?(host)
    end
  end
end
