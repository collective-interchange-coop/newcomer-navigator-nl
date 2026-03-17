# frozen_string_literal: true

require_relative 'lib/better_together_turnstile/version'

Gem::Specification.new do |spec|
  spec.name = 'better_together_turnstile'
  spec.version = BetterTogetherTurnstile::VERSION
  spec.authors = ['Better Together']
  spec.email = ['opensource@bettertogether.network']

  spec.summary = 'Reusable Cloudflare Turnstile integration for Better Together host apps.'
  spec.description = 'Provides controller concern and default Turnstile configuration for Better Together-based host applications.'
  spec.homepage = 'https://github.com/better-together-org/community-engine-rails'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.files = Dir['lib/**/*', 'README.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'better_together', '>= 0.10'
  spec.add_dependency 'cloudflare-turnstile-rails'
  spec.add_dependency 'railties', '>= 7.2', '< 9.0'
end
