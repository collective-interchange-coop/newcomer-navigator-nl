# frozen_string_literal: true

# Include the automatic test configuration from the community engine
require File.join(BetterTogether::Engine.root, 'spec', 'support', 'automatic_test_configuration.rb')

# Include other community engine test helpers
require File.join(BetterTogether::Engine.root, 'spec', 'support', 'better_together', 'devise_session_helpers.rb')
require File.join(BetterTogether::Engine.root, 'spec', 'support', 'request_spec_helper.rb')
