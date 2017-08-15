# frozen_string_literal: true

require 'qa/authorities'
require 'qa/ldf/empty_search_service'

module Qa
  module LDF
    ##
    # A Linked Data Fragments-based authority. Access linked data resources
    # through a caching server.
    #
    # @see LinkedDataFragments::CacheServer
    class Authority < Qa::Authorities::Base
      ##
      # The default linked data fragments client
      DEFAULT_DATASET_NAME = :''

      ##
      # The default linked data fragments client
      DEFAULT_CLIENT = Qa::LDF::Client

      ##
      # The default mapper
      DEFAULT_MAPPER = Qa::LDF::JsonMapper

      ##
      # The default search service
      DEFAULT_SEARCH_SERVICE = Qa::LDF::EmptySearchService

      class << self
        @@namespace_map = {}

        ##
        # Gives an authority class for the given namespace.
        #
        # @param namespace [#to_s] a URI-like namespace string
        #
        # @return [Authority]
        def for(namespace:)
          @@namespace_map.fetch(namespace.to_s) { self }.new
        end

        ##
        # @return [String] gives an empty string for no namespace,
        #   {#for_namespace} returns self in this case
        def namespace
          ''
        end

        ##
        # @return [Enumerable<String>]
        def namespaces
          @@namespace_map.keys
        end

        ##
        # Registers a namespace/class pair.
        #
        # @param namespace [#to_s] a URI-like namespace string
        # @param klass     [Class] an authority class
        #
        # @return [void]
        def register_namespace(namespace:, klass:)
          @@namespace_map[namespace.to_s] = klass
        end

        ##
        # Resets the namespaces
        #
        # @return [void]
        def reset_namespaces
          @@namespace_map = {}
        end
      end

      ##
      # @!attribute [rw] client
      #   @return [Client]
      # @!attribute [rw] dataset
      #   @return [Symbol] A dataset name (e.g. :lcsh)
      # @!attribute [rw] mapper
      #   @return [Mapper]
      # @!attribute [rw] search_service
      #   @return [#search]
      attr_writer :client, :dataset, :mapper, :search_service

      ##
      # @yieldparam authority [Authority] self
      def initialize(*)
        super
        yield self if block_given?
      end

      ##
      # @see Qa::Authorities::Base#all
      def all
        []
      end

      ##
      # Retrieves the given resource's JSON respresentation from the cache
      # server.
      #
      # The resource is retrieved through the client given by `#client`, and
      # mapped to JSON using `#mapper`.
      #
      # @see Qa::Authorities::Base#find
      # @see Qa::LDF::Client#get
      def find(id)
        mapper.map_resource(id, graph(id))
      end

      ##
      # @param uri [RDF::URI]
      # @return [RDF::Enumerable]
      def graph(uri)
        client.get(uri: uri, dataset: dataset)
      end

      ##
      # Search the vocabulary
      #
      # @param query [String] the query string
      #
      # @return [Array<Hash<Symbol, String>>] the response as a JSON friendly
      #   hash
      def search(query)
        search_service.search(query)
      end

      ##
      # @return [Qa::LDF::Client]
      def client
        @client ||= self.class::DEFAULT_CLIENT.new
      end

      ##
      # @return [Symbol]
      def dataset
        @dataset ||= self.class::DEFAULT_DATASET_NAME
      end

      ##
      # @return [JsonMapper]
      def mapper
        @mapper ||= self.class::DEFAULT_MAPPER.new
      end

      ##
      # @return [#search]
      def search_service
        @search_service ||= self.class::DEFAULT_SEARCH_SERVICE.new
      end
    end
  end
end
