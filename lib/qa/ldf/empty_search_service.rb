# frozen_string_literal: true

module Qa
  module LDF
    ##
    # A search service that always returns no results.
    #
    # @example
    #   EmptySearchService.new.search('any query') # => {}
    #
    class EmptySearchService
      ##
      # @see Qa::Authority::Base#search
      def search(_query)
        []
      end
    end
  end
end
