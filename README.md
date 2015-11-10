[![build](https://travis-ci.org/bodleian/datacite_mds.svg)](https://travis-ci.org/bodleian/datacite_mds)
[![Coverage Status](https://coveralls.io/repos/bodleian/datacite_mds/badge.svg?branch=master&service=github)](https://coveralls.io/github/bodleian/datacite_mds?branch=master)
[![MIT license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](https://github.com/bodleian/datacite_mds/blob/master/LICENSE.txt)
[![Gem Version](https://badge.fury.io/rb/datacite_mds.svg)](https://badge.fury.io/rb/datacite_mds)



## What is it?

This gem provides Ruby client connectivity to Datacite's [Metadata store](https://mds.datacite.org/) (MDS). The MDS is a service for data publishers to mint DOIs and register associated metadata. It is aimed mainly at scientific and research data publishers. This gem allows for simple and seamless interaction with the MDS service.



## Installation

Add this line to your application's Gemfile:

    gem 'datacite_mds'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install datacite_mds


## Usage

Require the gem

    require 'datacite_mds'

create an Mds object (explicit authorization)

    mds = Datacite::Mds.new authorize: {usr: "joe bloggs", pwd: "password"}

create an Mds object (implicit authorization via DATACITE_USR, DATACITE_PWD environment variables)

    mds = Datacite::Mds.new 

create an Mds object for testing (implicit authorization)

	mds = Datacite::Mds.new testing: true    

resolve a DOI

    res = mds.resolve '10.5072/existing-doi'
    p res # => <Net::HTTPOK 200 OK readbody=true

upload metadata

	res = mds.upload_metadata File.read('metadata.xml')
	p res # => <Net::HTTPCreated 201 Created readbody=true>

get all DOIs for datacentre

    res = mds.get_all_dois
    if res.instance_of? Net::HTTPOK
        p res.res.body.split # show all DOIs
    end


mint a DOI

	res = mds.mint '10.5072/non-existing-doi', 'http://ora.ox.ac.uk/objects/uuid:<an-existing-uuid>'
	p res # => <Net::HTTPCreated 201 Created readbody=true>	
	

update dataset for existing DOI

	res = mds.mint '10.5072/existing-doi', 'http://ora.ox.ac.uk/objects/uuid:<new-uuid>'	
	p res # => <Net::HTTPCreated 201 Created readbody=true>	

get metadata for existing DOI

  	res = mds.get_metadata '10.5072/existing-doi'
    if res.instance_of? Net::HTTPOK
        p res.body # shows the xml metadata
    end

## Tests

Minitest is used for testing. To run all tests, you must set the DATACITE_USR, DATACITE_PWD environment variables and then: 

    $ rake test

**Note**: Some of the tests use DOIs and URLs issued to the Bodleian Libraries and can be accessed only by using the Bodleian datacentre authorisation credentials. It is recommended that you substitute these constant variables' values in the test file, with your own datacentre's DOIs and URLs.     


## License

The gem is available as open source under the terms of the [MIT License](https://en.wikipedia.org/wiki/MIT_License), c/o The Chancellor Masters and Scholars of the University of Oxford.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

