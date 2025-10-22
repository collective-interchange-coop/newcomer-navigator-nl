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

  config.root('BetterTogether::Page') do |root|
  end

  config.root('BetterTogether::Person') do |root|
    root.exclude('conversations', 'created_conversations', 'conversation_participants', 'notifications',
                 'notification_mentions', 'contact_detail', 'phone_numbers', 'email_addresses', 'social_media_accounts', 'addresses', 'postal_addresses', 'physical_addresses', 'website_links')
  end

  # config.root('BetterTogether::Platform') do |root|
  # end

  config.root('BetterTogether::User') do |root|
  end

  config.customize('BetterTogether::User') do |u|
    # Reset password for all users to the same for ease of debugging on developer's machine
    # u['password'] = encrypt('password12345')
    u['created_at'] = Time.current
    # Please note that there you have only hash of record attributes, not the record itself!
  end

  config.customize('BetterTogether::Person') do |p|
    # p['name_en'] { Faker::Name.name }
  end

  # config.customize('BetterTogether::User') do |u|
  #   u['email'] { Faker::Internet.email }
  # end

  config.verbose = true
end
