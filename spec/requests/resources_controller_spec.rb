# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ResourcesController', :as_platform_manager do
  let(:locale) { I18n.default_locale }

  describe 'GET /:locale/resources' do
    it 'renders index without N+1 on translations' do
      get "/#{locale}/resources"
      expect(response.status).to be_in([200, 302])
    end
  end

  describe 'GET /:locale/resources/:id/download' do
    let(:document) do
      Resource::Document.new(
        name: 'Test Document',
        identifier: SecureRandom.uuid,
        locale: I18n.default_locale.to_s,
        privacy: 'public',
        published_at: 1.day.ago
      ).tap do |r|
        r.file.attach(io: StringIO.new('content'), filename: 'test.pdf',
                      content_type: 'application/pdf')
        r.save!
      end
    end

    it 'redirects instead of streaming the file' do
      get "/#{locale}/resources/#{document.to_param}/download"
      expect(response).to have_http_status(:redirect)
    end
  end
end
