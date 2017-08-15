# frozen_string_literal: true

module Qa
  module LDF
    ##
    # A customizable mapper from {RDF::Graph}s to JSON-like hashes for use in
    # Questioning Authority.
    #
    # @todo: Add configuration
    #
    # @example maps a graphs to QA JSON objects.
    #   mapper = JsonMapper.new
    #
    #   uri   = 'http://id.loc.gov/authorities/subjects/sh2004002557'
    #   graph = RDF::Graph.load(uri)
    #
    #   mapper.map_resource(uri, graph)
    #   # => { id:    'http://id.loc.gov/authorities/subjects/sh2004002557',
    #   #      label: 'Marble Island (Nunavut)' }
    #
    class JsonMapper
      ##
      # @param uri   [String] a URI-like string
      # @param graph [RDF::Queryable]
      #
      # @return [Hash<Symbol, String>]
      def map_resource(uri, graph)
        labels =
          graph.query(subject:   RDF::URI.intern(uri),
                      predicate: RDF::Vocab::SKOS.prefLabel).objects

        { id: uri, label: labels.first.to_s }
      end
    end
  end
end
