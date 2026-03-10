# frozen_string_literal: true

module NewcomerNavigatorNl
  # Canonicalizes Better Together helper URLs without replacing engine helpers.
  module BetterTogetherApplicationHelperOverride
    include NewcomerNavigatorNl::CanonicalUrlHelper

    def default_url_options
      super.merge(NewcomerNavigatorNl::CanonicalUrlOptions.base_url_options, locale: I18n.locale)
    end

    def host_community_logo_url
      canonical_absolute_url(super)
    end

    def open_graph_meta_tags
      safe_join(open_graph_tags.compact, "\n")
    end

    def canonical_link_tag
      target = content_for?(:canonical_url) ? content_for(:canonical_url) : request.fullpath
      tag.link(rel: 'canonical', href: canonical_absolute_url(target))
    end

    def hreflang_links
      tags = I18n.available_locales.map do |locale|
        path = url_for(locale:, only_path: true)
        tag.link(rel: 'alternate', hreflang: locale, href: canonical_absolute_url(path))
      end

      safe_join(tags, "\n")
    end

    private

    def open_graph_tags
      [
        tag.meta(property: 'og:title', content: open_graph_title),
        tag.meta(property: 'og:description', content: open_graph_description),
        tag.meta(property: 'og:url', content: open_graph_url),
        open_graph_image_tag,
        tag.meta(property: 'og:site_name', content: host_platform.name),
        tag.meta(property: 'og:type', content: 'website')
      ]
    end

    def open_graph_title
      return content_for(:og_title) if content_for?(:og_title)
      if content_for?(:page_title)
        return t('og.page.title', title: content_for(:page_title), platform_name: host_platform.name)
      end

      t('og.default_title', platform_name: host_platform.name)
    end

    def open_graph_description
      return content_for(:og_description) if content_for?(:og_description)

      t('og.default_description', platform_name: host_platform.name)
    end

    def open_graph_url
      target = content_for?(:og_url) ? content_for(:og_url) : request.fullpath
      canonical_absolute_url(target)
    end

    def open_graph_image
      image = content_for?(:og_image) ? content_for(:og_image) : host_community_logo_url
      canonical_absolute_url(image)
    end

    def open_graph_image_tag
      return unless open_graph_image.present?

      tag.meta(property: 'og:image', content: open_graph_image)
    end
  end
end
