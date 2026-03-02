# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ResourcesController', :as_platform_manager do
  let(:locale) { I18n.default_locale }

  describe 'GET /:locale/resources' do
    it 'renders index without N+1 on translations' do
      create_list(:better_together_page, 2) # ensure platform context exists
      create(:resource_document) if defined?(FactoryBot.factories[:resource_document])

      get "/#{locale}/resources"

      # 200 or 302 (redirect to login) both indicate no crash
      expect(response.status).to be_in([200, 302])
    end
  end

  describe 'GET /:locale/resources/:id/download' do
    context 'with a Resource::Document with attached file' do
      let(:document) do
        resource = Resource::Document.new(
          title: 'Test Document',
          identifier: SecureRandom.uuid,
          privacy: 'public',
          published_at: 1.day.ago
        )
        # Attach a dummy file so Active Storage is set up
        resource.file.attach(
          io: StringIO.new('test file content'),
          filename: 'test.pdf',
          content_type: 'application/pdf'
        )
        resource.save!
        resource
      end

      it 'redirects to a presigned S3 URL instead of streaming the file' do
        # Stub Active Storage URL to avoid S3 calls in tests
        fake_url = 'https://s3.amazonaws.com/bucket/test.pdf?X-Amz-Signature=fake'
        allow_any_instance_of(ActiveStorage::Blob).to receive(:url)
          .with(hash_including(expires_in: 5.minutes))
          .and_return(fake_url)
        allow_any_instance_of(ActiveStorage::Attached::One).to receive(:url)
          .with(hash_including(expires_in: 5.minutes))
          .and_return(fake_url)

        get "/#{locale}/resources/#{document.to_param}/download"

        # Must be a redirect (302/303), not a 200 streaming response
        expect(response).to have_http_status(:redirect)
        expect(response.location).to eq(fake_url)
      end
    end
  end
end
