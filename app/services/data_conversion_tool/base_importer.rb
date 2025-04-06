# frozen_string_literal: true

module DataConversionTool
  class BaseImporter
    include DataConversionTool::Helpers

    attr_reader :logs, :errors, :skipped_keys

    def initialize(logs: nil, errors: nil, skipped_keys: nil)
      @logs = logs || []
      @errors = errors || []
      @skipped_keys = skipped_keys || Set.new
    end

    def self.import_from_file(file_path)
      parsed_json = parse_json(file_path)
      new.import(parsed_json)
    end

    def self.parse_json(file_path)
      JSON.parse(File.read(file_path))
    rescue JSON::ParserError => e
      log_errors(e)
      raise 'Invalid JSON file'
    end

    def self.log_errors(exception)
      Rails.logger.error("JSON parsing failed: #{exception.message}")
    end

    # Instance Methods

    def import(_parsed_json)
      raise NotImplementedError, 'This method needs implementation in a subclass'
    end

    def summarize_logs
      unless @errors.empty?
        @logs << Logs.summarize_warnings_title
        @logs.concat(@errors)
      end

      return if @skipped_keys.empty?

      @logs << Logs.unknown_keys_title
      @logs.concat(@skipped_keys.to_a.sort.map { |k| "  - #{k}" })
    end
  end
end
