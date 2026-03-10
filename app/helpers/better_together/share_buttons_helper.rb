# frozen_string_literal: true

module BetterTogether
  module ShareButtonsHelper
    def share_buttons(platforms: BetterTogether::Metrics::Share::SHAREABLE_PLATFORMS, shareable: nil)
      url = canonical_absolute_url(request.fullpath)
      title = if shareable.respond_to?(:title)
                shareable&.title
              elsif shareable.respond_to?(:name)
                shareable&.name
              else
                I18n.t('better_together.share_buttons.default_title')
              end

      image = ''
      share_tracking_url = better_together.metrics_shares_path(locale: I18n.locale)
      shareable_type = shareable&.class&.name
      shareable_id = shareable&.id

      content_tag :div, data: { controller: 'better_together--share' }, class: 'social-share-buttons' do
        heading = content_tag(:div) { content_tag(:h5, I18n.t('better_together.share_buttons.share')) }

        buttons = content_tag :div do
          safe_join(platforms.map do |platform|
            link_to share_button_content(platform).html_safe, "#share-#{platform}",
                    class: "share-button share-#{platform}",
                    data: {
                      action: 'click->better_together--share#share',
                      platform:,
                      url:,
                      title:,
                      image:,
                      share_tracking_url:,
                      shareable_type:,
                      shareable_id:
                    },
                    aria: { label: I18n.t('better_together.share_buttons.aria_label', platform: platform.to_s.capitalize) },
                    rel: 'noopener noreferrer',
                    target: '_blank'
          end)
        end

        heading + buttons
      end
    end
  end
end
