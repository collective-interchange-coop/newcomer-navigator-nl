# frozen_string_literal: true

require 'uri'

module BetterTogether
  module ApplicationHelper
    TRANSPORT_HOST_ALIASES = %w[
      bts-5-zt.btsdev.ca
      bts-5-cf.btsdev.ca
      nnnl-prod-zt.btsdev.ca
      nnnl-prod-cf.btsdev.ca
      test.newcomernavigatornl.ca
      newcomernavigatornl.ca
    ].freeze

    def default_url_options
      super.merge(NewcomerNavigatorNl::CanonicalUrlOptions.base_url_options, locale: I18n.locale)
    end

    def host_community_logo_url
      return unless host_community.logo.attached?

      attachment = if host_community.respond_to?(:optimized_logo)
                     host_community.optimized_logo
                   else
                     host_community.logo
                   end

      rails_storage_proxy_url(attachment, **canonical_url_options)
    end

    def open_graph_meta_tags
      og_title = if content_for?(:og_title)
                   content_for(:og_title)
                 elsif content_for?(:page_title)
                   t('og.page.title', title: content_for(:page_title), platform_name: host_platform.name)
                 else
                   t('og.default_title', platform_name: host_platform.name)
                 end

      og_description = if content_for?(:og_description)
                         content_for(:og_description)
                       else
                         t('og.default_description', platform_name: host_platform.name)
                       end

      og_url = canonical_absolute_url(content_for?(:og_url) ? content_for(:og_url) : request.fullpath)
      og_image = if content_for?(:og_image)
                   canonical_absolute_url(content_for(:og_image))
                 else
                   host_community_logo_url
                 end

      tags = []
      tags << tag.meta(property: 'og:title', content: og_title)
      tags << tag.meta(property: 'og:description', content: og_description)
      tags << tag.meta(property: 'og:url', content: og_url)
      tags << tag.meta(property: 'og:image', content: og_image) if og_image.present?
      tags << tag.meta(property: 'og:site_name', content: host_platform.name)
      tags << tag.meta(property: 'og:type', content: 'website')

      safe_join(tags, "\n")
    end

    def canonical_link_tag
      canonical_url = if content_for?(:canonical_url)
                        content_for(:canonical_url)
                      else
                        request.fullpath
                      end

      tag.link(rel: 'canonical', href: canonical_absolute_url(canonical_url))
    end

    def hreflang_links
      tags = I18n.available_locales.map do |locale|
        localized_path = url_for(locale:, only_path: true)
        tag.link(rel: 'alternate', hreflang: locale, href: canonical_absolute_url(localized_path))
      end

      safe_join(tags, "\n")
    end

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

      uri = URI.parse(string)
      return string unless canonicalizable_origin_host?(uri.host)

      uri.scheme = canonical_url_options[:protocol]
      uri.host = canonical_url_options[:host]
      uri.port = canonical_url_options[:port]
      uri.to_s
    rescue URI::InvalidURIError
      "#{canonical_base_url}/#{string.sub(%r{\A/+}, '')}"
    end

    def canonicalizable_origin_host?(host)
      TRANSPORT_HOST_ALIASES.include?(host)
    end
  end
end
