# frozen_string_literal: true

module Qa
  module LDF
    ##
    # A search service that wraps another SearchService and casts its ids to a
    # namespace.
    #
    # @example
    #   nsify = Qa::LDF::NamespacedSearchService.new do |service|
    #     service.namespace      = 'http://example.com/ns/'
    #     service.parent_service = a_search_service_instance
    #   end
    #
    #   # when
    #   a_search_service_endpoint.search('moomin') # => { 'id' => 'blah' }
    #
    #   # then
    #   nsify.search('moomin') # => { 'id' => 'http://example.com/ns/blah' }
    #
    class NamespacedSearchService
      ##
      # @!attribute [rw] namespace
      #   @return [String]
      # @!attribute [rw] parent_service
      #   @return [#search]
      attr_accessor :namespace, :parent_service

      ##
      # @yieldparam service [NamespacedSearchService] yields self
      def initialize
        yield self
      end

      ##
      # @see Qa::Authority::Base#search
      def search(query)
        responses = parent_service.search(query)

        responses.map do |result|
          if result.keys.first.is_a?(Symbol)
            result[:id] = apply_namespace(result[:id])
          else
            result['id'] = apply_namespace(result['id'])
          end

          result
        end
      end

      def apply_namespace(id)
        return id if RDF::URI(id).valid?
        (RDF::URI(namespace) / id).to_s
      end
    end
  end
end
