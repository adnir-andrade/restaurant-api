# frozen_string_literal: true

module DataConversionTool
  module Helpers
    module KeyFinder
      def self.find(data, allowed_keys:)
        key = allowed_keys.find { |k| data.key?(k) }
        @unknown_keys ||= Set.new
        data.each_key { |k| @unknown_keys << k unless allowed_keys.include?(k) }
        key
      end

      def self.unknown_keys
        @unknown_keys.to_a
      end
    end
  end
end
