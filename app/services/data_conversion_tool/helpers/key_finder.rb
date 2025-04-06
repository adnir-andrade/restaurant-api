# frozen_string_literal: true

module DataConversionTool
  module Helpers
    module KeyFinder
      ALLOWED_ITEM_KEYS = %w[menu_items dishes items pratos plats].freeze

      def self.find(data)
        key = ALLOWED_ITEM_KEYS.find { |k| data.key?(k) }
        @unknown_keys ||= Set.new
        data.keys.each { |k| @unknown_keys << k unless ALLOWED_ITEM_KEYS.include?(k) }
        key
      end

      def self.unknown_keys
        @unknown_keys.to_a
      end
    end
  end
end
