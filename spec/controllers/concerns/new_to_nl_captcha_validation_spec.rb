# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewToNlCaptchaValidation, type: :concern do
  let(:controller_class) do
    Class.new(ActionController::Base) do
      include NewToNlCaptchaValidation

      def resource
        @resource ||= BetterTogether::User.new
      end

      def render(view, options = {})
        @rendered_view = view
        @render_options = options
      end

      def respond_with(resource)
        render :new, status: :unprocessable_entity, locals: { resource: resource, resource_name: :user }
      end

      attr_reader :rendered_view, :render_options
    end
  end

  let(:controller) { controller_class.new }

  describe '#validate_captcha_if_enabled?' do
    context 'when Turnstile gem is not loaded' do
      before do
        hide_const('Cloudflare::Turnstile::Rails')
      end

      it 'returns true (skips validation)' do
        result = controller.send(:validate_captcha_if_enabled?)
        expect(result).to be true
      end
    end

    context 'when Turnstile is configured with blank site key' do
      let(:config) { double('Config', site_key: '') } # rubocop:todo RSpec/VerifiedDoubles

      before do
        stub_const('Cloudflare::Turnstile::Rails', double(configuration: config))
      end

      it 'returns true (skips validation)' do
        result = controller.send(:validate_captcha_if_enabled?)
        expect(result).to be true
      end
    end

    context 'when Turnstile is properly configured' do
      let(:config) { double('Config', site_key: 'test_site_key') } # rubocop:todo RSpec/VerifiedDoubles

      before do
        stub_const('Cloudflare::Turnstile::Rails', double(configuration: config))
      end

      context 'with valid captcha' do # rubocop:todo RSpec/NestedGroups
        it 'returns true' do
          allow(controller).to receive(:valid_turnstile?).and_return(true)

          result = controller.send(:validate_captcha_if_enabled?)
          expect(result).to be true
        end
      end

      context 'with invalid captcha' do # rubocop:todo RSpec/NestedGroups
        it 'returns false' do
          allow(controller).to receive(:valid_turnstile?).and_return(false)

          result = controller.send(:validate_captcha_if_enabled?)
          expect(result).to be false
        end
      end
    end
  end

  describe '#handle_captcha_validation_failure' do
    let(:user_resource) do
      resource = double('User') # rubocop:todo RSpec/VerifiedDoubles
      errors = ActiveModel::Errors.new(resource)
      allow(resource).to receive(:errors).and_return(errors)
      resource
    end

    # rubocop:todo RSpec/MultipleExpectations
    it 'adds error message to resource and responds with form' do # rubocop:todo RSpec/ExampleLength, RSpec/MultipleExpectations
      # rubocop:enable RSpec/MultipleExpectations
      controller.send(:handle_captcha_validation_failure, user_resource)

      expect(user_resource.errors[:base]).to include(
        I18n.t('devise.registrations.new.captcha_failed')
      )
      expect(controller.rendered_view).to eq(:new)
      expect(controller.render_options[:status]).to eq(:unprocessable_entity)
    end
  end
end
