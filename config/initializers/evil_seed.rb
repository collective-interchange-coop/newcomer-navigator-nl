require 'evil_seed'

EvilSeed.configure do |config|
  # config.root('BetterTogether::Conversation') do |root|
  #   # Exclude everything
  #   root.exclude(/.*/)
  # end

  # config.root('BetterTogether::Message') do |root|
  #   # Exclude everything
  #   root.exclude(/.*/)
  # end

  # config.root('BetterTogether::Content::Block') do |root|
  #   root.exclude('creator', 'journey_items')
  # end

  config.ignore_columns('FriendlyId::Slug', :id)
  config.ignore_columns('Mobility::Backends::ActiveRecord::KeyValue::StringTranslation', :id)
  config.ignore_columns('Mobility::Backends::ActiveRecord::KeyValue::TextTranslation', :id)

  config.root('BetterTogether::Page') do |root|
    root.exclude('creator', 'authors', 'authorships',
                 'page_blocks.creator',
                 'page_blocks.block.creator',
                 'page_blocks.block.journey_items',
                 'views')
  end

  config.root('BetterTogether::NavigationArea') do |root|
    # root.exclude('creator')
  end

  config.root('Partner') do |root|
    root.exclude('creator', 'person_members', 'person_community_memberships', 'views')
    root.include('rich_text_translations', 'text_translations', 'string_translations')
  end

  # config.root('BetterTogether::Person') do |root|
  #   root.exclude('conversations', 'created_conversations', 'conversation_participants', 'notifications',
  #                'notification_mentions', 'contact_detail', 'phone_numbers', 'email_addresses', 'social_media_accounts', 'addresses', 'postal_addresses', 'physical_addresses', 'website_links')
  # end

  # config.root('BetterTogether::Platform') do |root|
  # end

  # config.root('BetterTogether::User') do |root|
  # end

  # config.customize('BetterTogether::Person') do |p|
  #   p['identifier'] = -> { Faker::Internet.unique.username(specifier: 10..20) }
  #   p['created_at'] = Time.current
  #   p['updated_at'] = Time.current
  # end

  # config.customize('BetterTogether::User') do |u|
  #   u['email'] = -> { Faker::Internet.email }
  #   u['created_at'] = Time.current
  #   u['updated_at'] = Time.current
  #   # Clear sensitive tokens
  #   u['reset_password_token'] = nil
  #   u['confirmation_token'] = nil
  #   u['unlock_token'] = nil
  # end

  config.verbose = true
  config.verbose_sql = true
end
