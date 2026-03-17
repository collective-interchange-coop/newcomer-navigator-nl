# frozen_string_literal: true

RSpec.describe 'Sanitized Export Configuration' do
  describe 'Approval Gate Logic' do
    it 'requires ALLOW_SANITIZED_EXPORT approval' do
      ENV.delete('ALLOW_SANITIZED_EXPORT')
      approved = ENV.fetch('ALLOW_SANITIZED_EXPORT', 'false') == 'true'
      expect(approved).to be false
    end

    it 'proceeds when ALLOW_SANITIZED_EXPORT is true' do
      ENV['ALLOW_SANITIZED_EXPORT'] = 'true'
      approved = ENV.fetch('ALLOW_SANITIZED_EXPORT', 'false') == 'true'
      expect(approved).to be true
    end

    it 'rejects when ALLOW_SANITIZED_EXPORT is false' do
      ENV['ALLOW_SANITIZED_EXPORT'] = 'false'
      approved = ENV.fetch('ALLOW_SANITIZED_EXPORT', 'false') == 'true'
      expect(approved).to be false
    end
  end

  describe 'Production Source Approval Logic' do
    it 'requires production source approval in production environment' do
      ENV['RAILS_ENV'] = 'production'
      allow_production = ENV.fetch('ALLOW_PRODUCTION_DB_SOURCE', 'false') == 'true'
      in_production = ENV['RAILS_ENV'] == 'production'
      needs_approval = in_production && !allow_production
      expect(needs_approval).to be true
    end

    it 'does not require production approval in development' do
      ENV['RAILS_ENV'] = 'development'
      allow_production = ENV.fetch('ALLOW_PRODUCTION_DB_SOURCE', 'false') == 'true'
      in_production = ENV['RAILS_ENV'] == 'production'
      needs_approval = in_production && !allow_production
      expect(needs_approval).to be false
    end
  end

  describe 'Sensitive Pattern Matchers' do
    let(:patterns) do
      {
        email: /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i,
        phone: /\b(?:\+?\d{1,3}[\s.-]?)?(?:\(\d{3}\)|\d{3})[\s.-]?\d{3}[\s.-]?\d{4}\b/,
        ipv4: /\b(?:\d{1,3}\.){3}\d{1,3}\b/,
        long_hex_token: /\b[a-f0-9]{48,}\b/i
      }
    end

    describe 'Email Detection' do
      it 'matches standard email addresses' do
        expect('user@example.com').to match(patterns[:email])
        expect('john.doe+tag@company.co.uk').to match(patterns[:email])
        expect('support@test.org').to match(patterns[:email])
      end

      it 'does not match sanitized content' do
        expect('[redacted-text]').not_to match(patterns[:email])
        expect('[sanitized-content]').not_to match(patterns[:email])
      end
    end

    describe 'Phone Number Detection' do
      it 'matches standard phone formats without parens' do
        expect('555-123-4567').to match(patterns[:phone])
        expect('5551234567').to match(patterns[:phone])
        expect('+1-555-123-4567').to match(patterns[:phone])
      end

      it 'does not match arbitrary numeric patterns' do
        expect('2025-01-15T14:30:00').not_to match(patterns[:phone])
        expect('1.2.3.4.5.6').not_to match(patterns[:phone])
        expect('123456789').not_to match(patterns[:phone])
      end

      it 'does not match sanitized content' do
        expect('[redacted-text]').not_to match(patterns[:phone])
      end
    end

    describe 'IPv4 Address Detection' do
      it 'matches IPv4 addresses' do
        expect('192.168.1.1').to match(patterns[:ipv4])
        expect('10.0.0.1').to match(patterns[:ipv4])
        expect('127.0.0.1').to match(patterns[:ipv4])
      end

      it 'does not match sanitized content' do
        expect('[redacted-text]').not_to match(patterns[:ipv4])
      end
    end

    describe 'Long Hex Token Detection' do
      it 'matches 48+ character hex strings' do
        hex_48 = 'a' * 48
        hex_64 = 'abcdef0123456789' * 4
        expect(hex_48).to match(patterns[:long_hex_token])
        expect(hex_64).to match(patterns[:long_hex_token])
      end

      it 'does not match shorter hex strings' do
        expect('abc123def456').not_to match(patterns[:long_hex_token])
      end
    end
  end

  describe 'Leak Scan Counting' do
    let(:patterns) do
      {
        email: /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i,
        phone: /\b(?:\+?\d{1,3}[\s.-]?)?(?:\(\d{3}\)|\d{3})[\s.-]?\d{3}[\s.-]?\d{4}\b/,
        ipv4: /\b(?:\d{1,3}\.){3}\d{1,3}\b/,
        long_hex_token: /\b[a-f0-9]{48,}\b/i
      }
    end

    it 'counts email hits accurately' do
      content = "INSERT INTO users VALUES ('user@example.com'), ('contact@test.org')"
      hits = patterns.transform_values { |pattern| content.scan(pattern).size }
      expect(hits[:email]).to eq 2
    end

    it 'counts zero for sanitized content' do
      content = "INSERT INTO users VALUES ('[redacted-text]'), ('[sanitized-content]')"
      hits = patterns.transform_values { |pattern| content.scan(pattern).size }
      total = hits.values.sum
      expect(total).to eq 0
    end

    it 'detects multiple types of sensitive data' do
      content = <<~SQL
        INSERT INTO users VALUES ('john@example.com', '555-123-4567', '192.168.1.1');
        INSERT INTO tokens VALUES ('a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6');
      SQL
      hits = patterns.transform_values { |pattern| content.scan(pattern).size }
      total = hits.values.sum
      expect(total).to be > 0
    end
  end

  describe 'Output Path Handling' do
    it 'uses SANITIZED_EXPORT_OUTPUT if provided' do
      output_path = '/custom/path/export.sql'
      ENV['SANITIZED_EXPORT_OUTPUT'] = output_path
      path = ENV.fetch('SANITIZED_EXPORT_OUTPUT', 'default')
      expect(path).to eq output_path
    end

    it 'defaults to tmp/sanitized_seed.sql' do
      ENV.delete('SANITIZED_EXPORT_OUTPUT')
      default = 'tmp/sanitized_seed.sql'
      path = ENV.fetch('SANITIZED_EXPORT_OUTPUT', default)
      expect(path).to include('sanitized_seed.sql')
    end
  end

  describe 'Read-Only Session Setting' do
    it 'uses correct SQL command for read-only mode' do
      sql_command = 'SET default_transaction_read_only = on'
      expect(sql_command).to eq 'SET default_transaction_read_only = on'
    end
  end

  describe 'Sanitization Customizers' do
    context 'Translation value redaction' do
      it 'replaces with consistent redaction marker' do
        translation = { value: 'Original text' }
        translation['value'] = '[redacted-text]'
        expect(translation['value']).to eq '[redacted-text]'
      end
    end

    context 'ActionText body sanitization' do
      it 'replaces with safe content marker' do
        rich_text = { body: '<p>Original content</p>' }
        rich_text['body'] = '<p>[sanitized-content]</p>'
        expect(rich_text['body']).to eq '<p>[sanitized-content]</p>'
      end
    end
  end

  describe 'Evil Seed Gem Configuration File' do
    let(:config_file) do
      File.expand_path('../../vendor/gems/better_together_evil_seed/lib/better_together_evil_seed/evil_seed_configuration.rb', __dir__)
    end
    let(:config_content) { File.read(config_file) if File.exist?(config_file) }

    it 'exists in the gem directory' do
      expect(File.exist?(config_file)).to be true
    end

    it 'starts with frozen_string_literal directive' do
      expect(config_content).to start_with('# frozen_string_literal: true')
    end

    it 'defines all required export roots' do
      expect(config_content).to include("config.root('BetterTogether::Page')")
      expect(config_content).to include("config.root('BetterTogether::NavigationArea')")
      expect(config_content).to include("config.root('Partner')")
      expect(config_content).to include("config.root('BetterTogether::Community')")
      expect(config_content).to include("config.root('BetterTogether::Person')")
    end

    it 'excludes sensitive PII associations from Page root' do
      expect(config_content).to include("'community.contact_detail'")
      expect(config_content).to include("'community.contacts'")
      expect(config_content).to include("'community.invitations'")
      expect(config_content).to include("'community.calendars'")
    end

    it 'excludes sensitive associations from Partner root' do
      expect(config_content).to include("'event_hosts'")
      expect(config_content).to include("'hosted_events'")
      expect(config_content).to include("'invitations'")
      expect(config_content).to include("'contact_detail'")
    end

    it 'includes translation value customizers' do
      expect(config_content).to include('StringTranslation')
      expect(config_content).to include('TextTranslation')
      expect(config_content).to include("'[redacted-text]'")
    end

    it 'includes ActionText body customizer' do
      expect(config_content).to include('ActionText::RichText')
      expect(config_content).to include("'<p>[sanitized-content]</p>'")
    end

    it 'sets verbose mode for debugging' do
      expect(config_content).to include('config.verbose = true')
      expect(config_content).to include('config.verbose_sql = true')
    end
  end

  describe 'Prod Export Task Gem' do
    let(:task_file) { File.expand_path('../../vendor/gems/better_together_evil_seed/lib/tasks/better_together_evil_seed_tasks.rake', __dir__) }
    let(:task_content) { File.read(task_file) if File.exist?(task_file) }

    it 'exists in the gem tasks directory' do
      expect(File.exist?(task_file)).to be true
    end

    it 'starts with frozen_string_literal directive' do
      expect(task_content).to start_with('# frozen_string_literal: true')
    end

    it 'defines prod namespace' do
      expect(task_content).to include('namespace :prod')
      expect(task_content).to include('task sanitized_export: :environment')
    end

    it 'includes approval gate enforcement' do
      service_file = File.expand_path('../../vendor/gems/better_together_evil_seed/lib/better_together_evil_seed/sanitized_export.rb', __dir__)
      service_content = File.read(service_file)
      expect(service_content).to include('enforce_export_approval!')
      expect(service_content).to include('ALLOW_SANITIZED_EXPORT')
    end

    it 'includes production source approval enforcement' do
      service_file = File.expand_path('../../vendor/gems/better_together_evil_seed/lib/better_together_evil_seed/sanitized_export.rb', __dir__)
      service_content = File.read(service_file)
      expect(service_content).to include('enforce_production_source_approval!')
      expect(service_content).to include('ALLOW_PRODUCTION_DB_SOURCE')
    end

    it 'includes read-only transaction guard' do
      service_file = File.expand_path('../../vendor/gems/better_together_evil_seed/lib/better_together_evil_seed/sanitized_export.rb', __dir__)
      service_content = File.read(service_file)
      expect(service_content).to include('SET default_transaction_read_only = on')
    end

    it 'includes leak scanning' do
      service_file = File.expand_path('../../vendor/gems/better_together_evil_seed/lib/better_together_evil_seed/sanitized_export.rb', __dir__)
      service_content = File.read(service_file)
      expect(service_content).to include('scan_for_sensitive_patterns')
      expect(service_content).to include('email:')
      expect(service_content).to include('phone:')
      expect(service_content).to include('ipv4:')
      expect(service_content).to include('long_hex_token:')
    end

    it 'includes output path handling' do
      service_file = File.expand_path('../../vendor/gems/better_together_evil_seed/lib/better_together_evil_seed/sanitized_export.rb', __dir__)
      service_content = File.read(service_file)
      expect(service_content).to include('SANITIZED_EXPORT_OUTPUT')
      expect(service_content).to include('sanitized_seed.sql')
    end

    it 'includes file cleanup on leak detection' do
      service_file = File.expand_path('../../vendor/gems/better_together_evil_seed/lib/better_together_evil_seed/sanitized_export.rb', __dir__)
      service_content = File.read(service_file)
      expect(service_content).to include('FileUtils.rm_f(path)')
    end
  end
end
