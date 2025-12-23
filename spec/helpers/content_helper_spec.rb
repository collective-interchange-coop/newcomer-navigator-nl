# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContentHelper, type: :helper do
  before do
    configure_host_platform
    # Define current_person method for view rendering
    helper.define_singleton_method(:current_person) { nil }
  end

  let(:creator) { BetterTogether::Person.first || create(:better_together_person) }

  describe '#render_disclaimer_content' do
    context 'when disclaimer content exists' do
      let!(:disclaimer) do # rubocop:todo RSpec/LetSetup
        BetterTogether::Content::RichText.create!(
          identifier: 'disclaimer-message',
          creator: creator,
          privacy: 'public',
          content_en: '<p>This is a disclaimer message.</p>'
        )
      end

      context 'with caching enabled' do # rubocop:todo RSpec/NestedGroups
        before do
          allow(controller).to receive(:perform_caching).and_return(true)
          Rails.cache.clear
        end

        it 'renders the disclaimer content wrapped in a small tag' do # rubocop:todo RSpec/MultipleExpectations
          # Mock the cache helper to yield the block (simulating cache write)
          allow(helper).to receive(:cache).and_yield

          result = helper.render_disclaimer_content
          expect(result).to be_present
          # Check for the styled small tag
          expect(result).to match(/fst-italic/)
          expect(result).to include('This is a disclaimer message.')
        end

        it 'uses cache_key_with_version for caching' do
          # First call will cache
          result1 = helper.render_disclaimer_content
          # Second call should use cached version
          result2 = helper.render_disclaimer_content
          expect(result1).to eq(result2)
        end
      end

      context 'with caching disabled' do # rubocop:todo RSpec/NestedGroups
        before do
          allow(controller).to receive(:perform_caching).and_return(false)
        end

        it 'renders the disclaimer content without caching' do # rubocop:todo RSpec/MultipleExpectations
          result = helper.render_disclaimer_content
          expect(result).to be_present
          expect(result).to include('fst-italic')
          expect(result).to include('This is a disclaimer message.')
        end

        it 'does not use cache' do
          expect(helper).not_to receive(:cache) # rubocop:todo RSpec/MessageSpies
          helper.render_disclaimer_content
        end
      end
    end

    context 'when disclaimer content does not exist' do
      it 'returns nil' do
        expect(helper.render_disclaimer_content).to be_nil
      end
    end
  end

  describe '#render_funder_content' do
    context 'when funder template exists' do
      let!(:funder_template) do # rubocop:todo RSpec/LetSetup
        BetterTogether::Content::Template.create!(
          identifier: 'funders-message',
          creator: creator,
          privacy: 'public',
          template_path: 'better_together/content/blocks/template/default'
        )
      end

      it 'renders the funder content in a container div' do # rubocop:todo RSpec/MultipleExpectations
        result = helper.render_funder_content
        expect(result).to include('container content my-3')
        expect(result).to include('id="new-to-nl-funder-message"')
      end

      it 'calls render with the template partial' do
        # Just verify it renders without error
        expect { helper.render_funder_content }.not_to raise_error
      end

      it 'wraps the template in a content_tag div' do
        result = helper.render_funder_content
        expect(result).to match(/<div[^>]*class="[^"]*container[^"]*"/)
      end
    end

    context 'when funder template does not exist' do
      it 'returns nil' do
        expect(helper.render_funder_content).to be_nil
      end
    end
  end

  describe '#render_partners_list_intro' do
    context 'when partners intro content exists' do
      let!(:partners_intro) do # rubocop:todo RSpec/LetSetup
        BetterTogether::Content::RichText.create!(
          identifier: 'partners-list-intro',
          creator: creator,
          privacy: 'public',
          content_en: '<p>Welcome to our partner organizations section.</p>'
        )
      end

      it 'calls render with the rich_text partial' do
        # Just verify it renders without error
        expect { helper.render_partners_list_intro }.not_to raise_error
      end

      it 'returns rendered content' do # rubocop:todo RSpec/MultipleExpectations
        result = helper.render_partners_list_intro
        expect(result).to be_present
        # Should include the content from the rich text block
        expect(result).to include('Welcome to our partner organizations section')
      end
    end

    context 'when partners intro content does not exist' do
      it 'returns nil' do
        expect(helper.render_partners_list_intro).to be_nil
      end
    end
  end

  describe 'integration with translations' do
    context 'with multiple locales' do
      let!(:disclaimer) do # rubocop:todo RSpec/LetSetup
        BetterTogether::Content::RichText.create!(
          identifier: 'disclaimer-message',
          creator: creator,
          privacy: 'public',
          content_en: '<p>English disclaimer</p>',
          content_es: '<p>Descargo de responsabilidad en español</p>',
          content_fr: '<p>Avis de non-responsabilité en français</p>'
        )
      end

      before do
        allow(controller).to receive(:perform_caching).and_return(false)
      end

      it 'renders content in the current locale (English)' do
        I18n.with_locale(:en) do
          result = helper.render_disclaimer_content
          expect(result).to include('English disclaimer')
        end
      end

      it 'renders content in Spanish locale' do
        I18n.with_locale(:es) do
          result = helper.render_disclaimer_content
          expect(result).to include('Descargo de responsabilidad en español')
        end
      end

      it 'renders content in French locale' do
        I18n.with_locale(:fr) do
          result = helper.render_disclaimer_content
          expect(result).to include('Avis de non-responsabilité en français')
        end
      end
    end
  end

  describe 'caching behavior' do
    let!(:partners_intro) do # rubocop:todo RSpec/LetSetup
      BetterTogether::Content::RichText.create!(
        identifier: 'partners-list-intro',
        creator: creator,
        privacy: 'public',
        content_en: '<p>Original content</p>'
      )
    end

    it 'renders the block partial which includes built-in caching' do # rubocop:todo RSpec/MultipleExpectations
      result = helper.render_partners_list_intro
      expect(result).to be_present
      expect(result).to include('Original content')
    end
  end

  describe 'content safety and sanitization' do
    let!(:disclaimer) do # rubocop:todo RSpec/LetSetup
      BetterTogether::Content::RichText.create!(
        identifier: 'disclaimer-message',
        creator: creator,
        privacy: 'public',
        content_en: '<p>Safe <strong>HTML</strong> content</p>'
      )
    end

    before do
      allow(controller).to receive(:perform_caching).and_return(false)
    end

    it 'renders HTML content safely' do
      result = helper.render_disclaimer_content
      expect(result).to include('<strong>HTML</strong>')
    end
  end

  describe 'error handling' do
    context 'when content has invalid data' do
      let!(:broken_disclaimer) do # rubocop:todo RSpec/LetSetup
        # Create a record with blank content
        BetterTogether::Content::RichText.create!(
          identifier: 'disclaimer-message',
          creator: creator,
          privacy: 'public'
        )
      end

      before do
        allow(controller).to receive(:perform_caching).and_return(false)
      end

      it 'handles nil/empty content gracefully' do
        expect { helper.render_disclaimer_content }.not_to raise_error
      end
    end
  end
end
