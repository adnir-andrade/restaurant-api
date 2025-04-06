module DataConversionTool
  class BaseImporter
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

    def self.log_errors(e)
      Rails.logger.error("JSON parsing failed: #{e.message}")
    end

    # Instance Methods

    def import(_parsed_json)
      raise NotImplementedError, 'This method needs implementation in a subclass'
    end
  end
end
