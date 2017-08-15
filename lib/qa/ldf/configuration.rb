# frozen_string_literal: true

require 'singleton'

module Qa
  module LDF
    ##
    # A singleton configuration class.
    #
    # This behaves much like a hash, but guarantees that only one configuration
    # exists and accepts a block sytax for configuration.
    #
    # @example configuring with a configuration hash
    #   Qa::LDF::Configuration.instance
    #     .configure!(endpoint: 'http://example.org/ldf/')
    #
    # @example configuring with block syntax
    #   Qa::LDF::Configuration.instance.configure! do |config|
    #     config[:endpoint] = 'http://example.org/ldf/'
    #   end
    #
    # @see Qa::LDF.config
    # @see Qa::LDF.configure!
    class Configuration
      extend Forwardable
      include Singleton

      ##
      # @!macro [attach] def_delegator
      #   @!method $3()
      #     Delegates to the underlying options
      def_delegator :@options, :'[]', :'[]'
      def_delegator :@options, :'[]=', :'[]='
      def_delegator :@options, :any?, :any?
      def_delegator :@options, :each, :each
      def_delegator :@options, :fetch, :fetch
      def_delegator :@options, :to_a, :to_a
      def_delegator :@options, :to_h, :to_h

      ##
      # @private
      # @see Singleton
      def initialize
        @options = {}
      end

      ##
      # @param opts [Hash]
      #   @option endpoint [String]
      #
      # @yield yields self to block
      # @yieldparam config [Configuration] self
      def configure!(**opts)
        @options = opts
        yield self if block_given?
        self
      end

      ##
      # Empties all configuration options
      #
      # @return opts [Hash]
      def reset!
        @options = {}
      end
    end
  end
end
