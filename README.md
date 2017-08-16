QuestioningAuthority::LDF
=========================
[![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)

This sofware providies bindings from [Questioning Authority](https://github.com/samvera/questioning_authority) to the [linked data caching fragment server](https://github.com/ActiveTriples/linked-data-fragments) for fast query of RDF-based authorities.

What Does This Do?
------------------

This gem offers a caching version of the [Questioning Authority](https://github.com/samvera/questioning_authority) interface relying on the ActiveTriples LDF caching service. A set of linked data "authorities" are exposed through the Questioning Authority API, and cached for fast recall using the Linked Data Fragments Caching Server. Models on the Samvera/Rails side are provided to handle caching and easy presentation of labels.

Both the QA and LDF APIs are available in mountable forms, so they can run directly in your Samvera application---see below for details.

### Why use this?

The main reason you may be interested in this software is to handle local caching of linked data references in your metadata.

### Upcoming features include:

  - Support for `Qa::Authority::Base#all` for all LDF authorities through [Hydra Core Partial Collection View](http://www.hydra-cg.com/spec/latest/core/#hydra:PartialCollectionView) style paging.
  - A default search, accessing only cached items.

How Does it Work?
-----------------

### [TK] Architecture Overview.

### Mounting and configuring the LDF caching server

The LDF caching server can run as a mounted application within Rails. To use the caching server, add the following to your `Gemfile`:

```ruby
gem 'qa-ldf', '~>0.3.0'

# for now use the active branch of the linked data caching fragment server
gem 'ld_cache_fragment', github: 'ActiveTriples/linked-data-fragments', branch: 'feature/multi-dataset'
```

Then you need to mount the application to an unused route:

```ruby
# config/routes.rb

Rails.application.routes.draw do
  # ...
  mount LinkedDataFragments::CacheServer::APPLICATION => '/ldcache'
  # ...
end
```
And add an `ldf.yml` configuration.

```yaml
# config/ldf.yml
development:
  uri_endpoint: 'http://localhost:3000/ldcache/{?subject}'
  uri_root: 'http://localhost:3000/ldcache'
  cache_backend:
    provider: 'repository'
test: &TEST_
  uri_endpoint: 'http://localhost:3000/ldcache/{?subject}'
  uri_root: 'http://localhost:3000/ldcache'
  cache_backend:
provider: 'repository'
  production:
  uri_endpoint: 'http://localhost:3000/ldcache/{?subject}'
  uri_root: 'http://localhost:3000/ldcache'
  cache_backend:
    provider: 'marmotta'
```

You should now be able to access the ldcache endpoint at `http://example.com/ldcache`. That address will return a dataset description for the root dataset. Queries sent to that endpoint access the transparent cache. For example:

    http://example.com/ldcache/?subject=http://id.loc.gov/authorities/subjects/sh2004002556

will pass the request through to the Library of Congress on the first request, subsequent requests are retrieved from the cached.

Finally, configure `Qa::LDF` to aim at the cache server:

```ruby
Qa::LDF.configure!(endpoint: LinkedDataFragments::Settings.uri_root)
```

In a Samvera app, the best place to put this is in an initializer, e.g. `config/initializers/samvera_config.rb`.

#### Datasets

The cache server uses [RDF Datasets](http://www.hydra-cg.com/spec/latest/linked-data-fragments/#datasets) to manage sperate cache spaces. The root dataset is at the server root (`http://example.com/ldcache`, above), and additional datasets are available at any `dataset/*` path following from the root. The `Qa::LDF` authorities are configured to use independent datasets, so each authority corresponds to a cache space of its own. Each dataset provides its own description at its base path, and is queryable with `?subject=` queries as demonstrated above.

#### Selecting a Triplestore Backend

The caching server provides several backends for persistent storage, we recommend using the Marmotta backend, but a Blazegraph backend (untested with this gem) is also provided. Read the [ActiveTriples::LinkedDataFragments documentation on backend configuration](https://github.com/ActiveTriples/linked-data-fragments#configuration) for more.

#### LDF caching as an external service.

The LDF caching server can run independently from your Samvera application as a lightweight, generic [Rack](http://www.rubydoc.info/github/rack/rack/file/SPEC) application, or as a standalone Rails app. You may want to deploy the server in this way so it can run on separate hardware, or to segregate Linked Data "follow your nose" network traffic.

The simplest way to get a working application that will run on any Rack-compatible server is to create a `./config.ru` containing:

```ruby
# ./config.ru
require 'ld_cache_fragment/cache_server'

run LinkedDataFragments::CacheServer::APPLICATION
```

With this in your working directory, you can run `$ rackup` to launch a basic server. More robust deployments are possible using servers like [Puma](https://github.com/puma/puma#rackup).

#### [TK] LDF caching as a Rails app

Authority Sources
----------------------

### LCNAF

A caching interface to the Library of Congress Name Authority File is implemented as a QA authority as `Qa::LDF::LCNames`. This uses the same search code deployed by the generic LC authorities provided by QA, but provides `id.loc.gov` results. This authority is aliased to `Qa::Lcnames` pending closure of https://github.com/samvera/questioning_authority/issues/137. It is available at the endpoint `authorities/search/lcnames`.

### FAST

A similar interface to FAST (Faceted Application of Subject Terminology) is in `Qa::LDF::FAST`. This authority is aliased to `Qa::Fast`, and is available at `authorities/search/fast`.

Configuring authorities
-----------------------

### [TK] Models.

### Forms

Autocomplete handling for Questioning Authority is provided by Sufia/Hyrax. To this handling, we add a custom dropdown for selecting from multiple authorities in a field.

# Hyrax Autocomplete

You've got a `Work` in Hyrax and it has a `Creator` field. Wouldn't it be nice to have autocomplete on that form with a controlled vocabulary? Hyrax has this functionality, but you need to set some things up first.

The most basic way a field is associated with a particular autocomplete data source is with a data attribute on the element. The `data-autocomplete-url` attribute stores a path to the data source. To add one to an existing field create a partial for the field in `app/views/records/edit_fields/`.

In the partial, specify the data source:

```erb
<%=
  f.input key,
  as: :multi_value,
  input_html: {
  class: 'form-control',
  data: { 'autocomplete-url' => "/authorities/search/loc/names",
          'autocomplete' => key }
        } ,
  required: f.object.required?(key) %>
```

Hyrax comes with [Questioning Authority](https://github.com/samvera/questioning_authority) which provides some RESTful endpoints that you can use as autocomplete sources. Checkout the QA README for a list of the authorities that it comes with (you can even make your own).

When the Hyrax form for your `Work` loads the autocomplete JavaScript is initialized for certain fields. For the `Creator` field that we created a partial for, all we needed to was add the data attribute and the autocomplete is activated.

If the field is not one of the default fields, you'll need to run this to activate autocomplete on the field:

```js
var Autocomplete = require('hyrax/autocomplete');
var autocomplete = new Autocomplete({
  "autocompleteFields":
    ["subject","language","creator","based_near","work"]
  });
$('.multi_value.form-group').manage_fields({
  add: function(e, element) {
    autocomplete.fieldAdded(element)
  }
});
autocomplete.setup();
```

You just need to pass the fields when creating an Autocomplete instance.

Autocomplete in Hyrax currently uses jQuery UI Autocomplete. Hyrax stores the [jQuery UI Autocomplete options and source](http://jqueryui.com/autocomplete/#remote-jsonp) in ES6 classes. Unless you need to make specific query that requires you to change the options and source, the JS will use a default query from [default.es6](https://github.com/samvera/hyrax/blob/master/app/assets/javascripts/hyrax/autocomplete/default.es6). This should just work with the QA vocabs.

The autocomplete for the `Work` field requires different a different source and options so it has a different class: [work.es6](https://github.com/samvera/hyrax/blob/master/app/assets/javascripts/hyrax/autocomplete/work.es6).
After creating your own class, you will need to import it and an additional case to the autocomplete method in [autocomplete.es6](https://github.com/samvera/hyrax/blob/master/app/assets/javascripts/hyrax/autocomplete.es6)

#### Adding Controlled Vocabulary Dropdown Options

To create your own dropdown with authorities you extend the `QASelectService` class. By convention, we place this in `app/services`.

```ruby
# app/services/name_authorities.rb
class NameAuthorities < QaSelectService
  def initialize
    super('names')
  end
end
```

Initialize the service with the name of a YAML file `names.yml` that contains a list of authorities:

```yaml
terms:
  - id: /authorities/search/loc/names
    term: LOC Names
    active: true
  - id: /authorities/search/assign_fast/all
    term: FAST
    active: true
```

Then in the partials for the input field at `app/views/records/edit_fields/_creator.html.erb`:

```erb
<% name_authorities = Hyrax::NameAuthorities.new %>

<%=
  f.input key,
    as: :multi_value,
    input_html: {
      class: 'form-control',
      data: { 'autocomplete-url' => name_authorities.select_active_options.first.last,
              'autocomplete' => key } } ,
      required: f.object.required?(key) %>

<%= f.input key, collection: name_authorities.select_active_options, label: false %>
```

Implementing Custom Authorities
-------------------------------

Custom (local) authorities can be included by placing a YAML configuration in `config/authorities`. This configuration should specific a list of terms, and give an `id`, `term` name, and `active` flag for each of them. Terms can be set `inactive` to disable them.

```yaml
# config/authorities/moomin_valley.yml
terms:
  - id:      http://example.com/moomin
    term:   'Moomin'
    active: true
  - id:      http://example.com/moomin_papa
    term:   'Moomin Papa'
    active: true
  - id:      http://example.com/moomin_mama
    term:   'Moomin Mama'
    active: true
  - id:      http://example.com/snorkmaiden
    term:   'Snorkmaiden'
    active: true
```

These terms are now available from Questioning Authority at `/authorities/search/local/moomin_valley'.

License
-------

This software is available under the <a href="https://raw.githubusercontent.com/curationexperts/qa-ldf/master/LICENSE">Apache 2.0 License</a>.

Acknowledgements
----------------

<a href="https://www.chemheritage.org/" >
<img src="https://raw.githubusercontent.com/curationexperts/qa-ldf/1e09875605fa979a2981cc6a5c5f823b935530a3/readme_logos/CHF_logo_primary_tagline.jpg" width="25%"></a>
</br>
<a href="https://www.imls.gov/">
<img src="https://raw.githubusercontent.com/curationexperts/qa-ldf/1e09875605fa979a2981cc6a5c5f823b935530a3/readme_logos/imls_logo_2c.jpg" width="25%"></a>

This project was made possible in part by the Institute of Museum and Library Services grant SP-02-16-0014-16.
