# frozen_string_literal: true

# Load the community engine's request spec helper first
engine_helper_path = File.join(BetterTogether::Engine.root, 'spec', 'support', 'request_spec_helper.rb')
require engine_helper_path if File.exist?(engine_helper_path)

module RequestSpecHelper
  def json
    JSON.parse(response.body)
  end

  # Override the login method if needed for this specific platform
  def login(email, password)
    post better_together.user_session_path, params: {
      user: { email: email, password: password }
    }
  end
end
