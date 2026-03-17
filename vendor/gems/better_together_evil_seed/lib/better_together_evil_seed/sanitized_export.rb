# frozen_string_literal: true

require 'fileutils'

module BetterTogetherEvilSeed
  module SanitizedExport
    module_function

    def output_path
      ENV.fetch('SANITIZED_EXPORT_OUTPUT', Rails.root.join('tmp', 'sanitized_seed.sql').to_s)
    end

    def enforce_export_approval!
      approved = ENV.fetch('ALLOW_SANITIZED_EXPORT', 'false') == 'true'
      abort 'Refusing export. Set ALLOW_SANITIZED_EXPORT=true to proceed.' unless approved
    end

    def enforce_production_source_approval!
      allow_production = ENV.fetch('ALLOW_PRODUCTION_DB_SOURCE', 'false') == 'true'
      return unless Rails.env.production? && !allow_production

      abort 'Refusing export from production environment. Set ALLOW_PRODUCTION_DB_SOURCE=true to proceed.'
    end

    def prepare_output_file(path)
      FileUtils.mkdir_p(File.dirname(path))
      FileUtils.rm_f(path)
    end

    def scan_for_sensitive_patterns(path)
      sql = File.read(path)

      patterns = {
        email: /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i,
        phone: /\b(?:\+?\d{1,3}[\s.-]?)?(?:\(\d{3}\)|\d{3})[\s.-]?\d{3}[\s.-]?\d{4}\b/,
        ipv4: /\b(?:\d{1,3}\.){3}\d{1,3}\b/,
        long_hex_token: /\b[a-f0-9]{48,}\b/i
      }

      hits = patterns.transform_values { |pattern| sql.scan(pattern).size }
      { hits: hits, total_hits: hits.values.sum }
    end

    def validate_export!(path) # rubocop:disable Metrics/MethodLength
      leak_report = scan_for_sensitive_patterns(path)
      return if leak_report[:total_hits].zero?

      FileUtils.rm_f(path)
      puts "Sensitive data scan failed for #{path}."
      leak_report[:hits].each do |name, count|
        puts "- #{name}: #{count}" if count.positive?
      end

      abort 'Export removed due to detected sensitive patterns.'
    ensure
      puts "Sanitized export completed: #{path}" if File.exist?(path)
      puts 'Leak scan passed with zero sensitive-pattern hits.' if leak_report && leak_report[:total_hits].zero?
    end

    def run!
      path = output_path

      enforce_export_approval!
      enforce_production_source_approval!
      require 'evil_seed'

      prepare_output_file(path)
      ActiveRecord::Base.connection.execute('SET default_transaction_read_only = on')
      EvilSeed.dump(path)
      validate_export!(path)
    end
  end
end
