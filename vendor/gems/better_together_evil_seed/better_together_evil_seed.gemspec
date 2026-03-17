# frozen_string_literal: true

require_relative 'lib/better_together_evil_seed/version'

Gem::Specification.new do |spec|
  spec.name = 'better_together_evil_seed'
  spec.version = BetterTogetherEvilSeed::VERSION
  spec.authors = ['Better Together']
  spec.email = ['opensource@bettertogether.network']

  spec.summary = 'Reusable Evil Seed export capability for Better Together host apps.'
  spec.description = 'Provides standardized Evil Seed configuration and sanitized export rake task for Better Together-based host applications.'
  spec.homepage = 'https://github.com/better-together-org/community-engine-rails'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.files = Dir['lib/**/*', 'README.md']
  spec.require_paths = ['lib']

  spec.add_dependency 'better_together', '>= 0.10'
  spec.add_dependency 'evil-seed', '>= 0.7.0'
  spec.add_dependency 'railties', '>= 7.2', '< 9.0'
end
