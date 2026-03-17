# frozen_string_literal: true

module NewcomerNavigatorNl
  # Keeps share payloads on the public NNNL hostname while preserving engine helpers.
  module BetterTogetherShareButtonsHelperOverride
    include NewcomerNavigatorNl::CanonicalUrlHelper

    def share_buttons(platforms: BetterTogether::Metrics::Share::SHAREABLE_PLATFORMS, shareable: nil)
      content_tag :div, data: { controller: 'better_together--share' }, class: 'social-share-buttons' do
        share_buttons_heading + share_buttons_list(platforms:, shareable:)
      end
    end

    private

    def share_buttons_heading
      content_tag(:div) { content_tag(:h5, I18n.t('better_together.share_buttons.share')) }
    end

    def share_buttons_list(platforms:, shareable:)
      content_tag :div do
        safe_join(platforms.map { |platform| share_button_link(platform, shareable) })
      end
    end

    def share_button_link(platform, shareable)
      link_to share_button_content(platform).html_safe, "#share-#{platform}",
              class: "share-button share-#{platform}",
              data: share_button_data(platform:, shareable:),
              aria: { label: share_button_aria_label(platform) },
              rel: 'noopener noreferrer',
              target: '_blank'
    end

    def share_button_data(platform:, shareable:)
      {
        action: 'click->better_together--share#share',
        platform:,
        url: canonical_absolute_url(request.fullpath),
        title: share_button_title(shareable),
        image: '',
        share_tracking_url: better_together.metrics_shares_path(locale: I18n.locale),
        shareable_type: shareable&.class&.name,
        shareable_id: shareable&.id
      }
    end

    def share_button_title(shareable)
      return shareable.title if shareable.respond_to?(:title)
      return shareable.name if shareable.respond_to?(:name)

      I18n.t('better_together.share_buttons.default_title')
    end

    def share_button_aria_label(platform)
      I18n.t('better_together.share_buttons.aria_label', platform: platform.to_s.capitalize)
    end
  end
end
