# frozen_string_literal: true

begin
  require 'evil_seed'
rescue LoadError
  if defined?(Rails)
    Rails.logger.info('[evil_seed] gem not available; sanitized export tasks disabled in this environment')
  end
else
  EvilSeed.configure do |config| # rubocop:disable Metrics/BlockLength
    config.ignore_columns('FriendlyId::Slug', :id)
    config.ignore_columns('Mobility::Backends::ActiveRecord::KeyValue::StringTranslation', :id)
    config.ignore_columns('Mobility::Backends::ActiveRecord::KeyValue::TextTranslation', :id)

    config.root('BetterTogether::Page') do |root|
      root.exclude('creator', 'authors', 'authorships',
                   'page_blocks.creator',
                   'page_blocks.block.creator',
                   'page_blocks.block.journey_items',
                   'views',
                   'community.contact_detail',
                   'community.contacts',
                   'community.person_community_memberships',
                   'community.person_members',
                   'community.invitations',
                   'community.calendars',
                   'community.default_calendar')
    end

    config.root('BetterTogether::NavigationArea') do |root|
      root.exclude('creator', 'views')
    end

    config.root('Partner') do |root|
      root.exclude('creator',
                   'person_members',
                   'person_community_memberships',
                   'views',
                   'event_hosts',
                   'hosted_events',
                   'calendars',
                   'default_calendar',
                   'invitations',
                   'contact_detail',
                   'contacts')
      root.include('rich_text_translations', 'text_translations', 'string_translations')
    end

    # BetterTogether::Community: exclude all sensitive PII associations
    # including contact details, invitations, and user relationship data
    config.root('BetterTogether::Community') do |root|
      root.exclude('contact_detail',
                   'contacts',
                   'contact_details',
                   'invitations',
                   'platform_invitations',
                   'calendars',
                   'default_calendar',
                   'person_community_memberships',
                   'person_members',
                   'users')
    end

    # BetterTogether::Person: exclude all sensitive PII associations
    # user credentials, contact details, and authentication tokens are never exported
    config.root('BetterTogether::Person') do |root|
      root.exclude('conversations',
                   'created_conversations',
                   'conversation_participants',
                   'notifications',
                   'notification_mentions',
                   'contact_detail',
                   'phone_numbers',
                   'email_addresses',
                   'social_media_accounts',
                   'addresses',
                   'postal_addresses',
                   'physical_addresses',
                   'website_links',
                   'user',
                   'users')
    end

    config.customize('Mobility::Backends::ActiveRecord::KeyValue::StringTranslation') do |t|
      t['value'] = '[redacted-text]'
    end

    config.customize('Mobility::Backends::ActiveRecord::KeyValue::TextTranslation') do |t|
      t['value'] = '[redacted-text]'
    end

    config.customize('ActionText::RichText') do |rich_text|
      rich_text['body'] = '<p>[sanitized-content]</p>'
    end

    config.verbose = true
    config.verbose_sql = true
  end
end
