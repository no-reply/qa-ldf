require 'spec_helper'

describe Qa::LDF::FAST do
  it_behaves_like 'an ldf authority'

  subject(:authority) do
    auth = described_class.new

    auth.client = FakeClient.new do |client|
      client.graph = RDF::Graph.new
      client.graph.insert(*statements)
      client.label = ldf_label
    end

    auth
  end

  let(:statements) do
    [RDF::Statement(RDF::URI(ldf_uri),
                    RDF::Vocab::SKOS.prefLabel,
                    RDF::Literal(ldf_label))]
  end

  let(:ldf_label) { 'Jansson, Tove' }
  let(:ldf_uri)   { 'http://id.worldcat.org/fast/34647' }

  before do
    # mock empty responses for all queries;
    # @todo contract test AssignFast authority
    body = <<-eos
{
  "responseHeader":{
    "status":0,
    "QTime":468,
    "params":{
      "fl":"suggestall,idroot,auth,type",
      "q":"suggestall:nothing_to_see_here",
      "rows":"20"
     }
   },
  "response":{"numFound":0,"start":0,"docs":[]}
}
eos

    stub_request(:get, 'http://fast.oclc.org/searchfast/fastsuggest?' \
                       'query=tove&queryIndex=suggestall&' \
                       'queryReturn=suggestall,idroot,auth,type&' \
                       'rows=20&suggest=autoSubject')
      .with(headers: { 'Accept' => 'application/json' })
      .to_return(status: 200, body: body, headers: {})
  end

  describe '#dataset' do
    it 'defaults to :fast' do
      expect(described_class.new.dataset).to eq :fast
    end
  end
end
