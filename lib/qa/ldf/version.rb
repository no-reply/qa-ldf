# frozen_string_literal: true

module Qa
  module LDF
    ##
    # Gives the current version, parsed from `VERSION`.
    #
    # @example
    #   "The current version is: #{Qa::LDF::VERSION}"
    #
    module VERSION
      FILE = File.expand_path('../../../../VERSION', __FILE__)
      MAJOR, MINOR, TINY = File.read(FILE).chomp.split('.')
      STRING = [MAJOR, MINOR, TINY].compact.join('.').freeze

      ##
      # @return [String]
      def self.to_s
        STRING
      end

      ##
      # @return [String]
      def self.to_str
        STRING
      end

      ##
      # @return [Array(String, String, String, String)]
      def self.to_a
        [MAJOR, MINOR, TINY].compact
      end
    end
  end
end
