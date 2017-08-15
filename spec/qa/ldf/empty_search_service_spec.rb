# coding: utf-8

require 'spec_helper'
require 'qa/ldf/empty_search_service'

describe Qa::LDF::EmptySearchService do
  it_behaves_like 'an ldf search service'

  subject(:search_service) { described_class.new }

  let(:searches) { { '-NonSensE\ !QUERY' => [], 'Bărăganul (Romania)' => [] } }
end
