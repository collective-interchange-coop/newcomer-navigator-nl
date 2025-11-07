# frozen_string_literal: true

module ContentHelper # rubocop:todo Style/Documentation
  def render_disclaimer_content
    disclaimer = BetterTogether::Content::RichText.find_by(identifier: 'disclaimer-message')

    return unless disclaimer

    content = content_tag :small, disclaimer.content, class: 'fst-italic', style: 'font-size: 0.6em;'

    if controller.perform_caching
      cache disclaimer.cache_key_with_version do
        content
      end
    else
      content
    end
  end

  def render_funder_content
    funder = BetterTogether::Content::Template.find_by(identifier: 'funders-message')

    return unless funder

    content_tag :div, class: 'container content my-3', id: 'new-to-nl-funder-message' do
      render partial: 'better_together/content/blocks/template', locals: { template: funder }
    end
  end
  end
end
