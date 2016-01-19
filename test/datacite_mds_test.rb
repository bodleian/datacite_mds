require 'test_helper'

class DataciteMdsTest < Minitest::Test

  # tests have been designed to reflect the Datacite MDS API documentation  https://mds.datacite.org/static/apidoc

  NON_EXISTING_DOI_2 = '10.5072/BODLEIAN:xxxORATEST16'
  NON_EXISTING_DOI_1 = '10.5072/BODLEIAN:xxxyy'
  EXISTING_DOI = '10.5287/BODLEIAN:DR26XX70W'
  EXISTING_URL = 'http://ora.ox.ac.uk/objects/uuid:37897aec-0a18-46f6-b6a7-dd8690fa2797'

  METADATA_1 = ( File.read( File.dirname(__FILE__) + '/data_samples/metadata1.xml' ) )

  METADATA_2 = ( File.read( File.dirname(__FILE__) + '/data_samples/metadata2.xml' ) )

  MALFORMED_METADATA = ( File.read( File.dirname(__FILE__) + '/data_samples/malformed_metadata.xml' ) )

  INVALID_METADATA = ( File.read( File.dirname(__FILE__) + '/data_samples/invalid_metadata.xml' ) )




  def setup
    @mds = Datacite::Mds.new(testing: true)
  end


  def test_that_it_has_a_version_number
    refute_nil ::DataciteMds::VERSION
  end

  ### GET (resolve a specific DOI)

  def test_it_resolves_existing_doi
    res = @mds.resolve EXISTING_DOI
    assert_instance_of Net::HTTPOK, res
    assert_equal EXISTING_URL, res.body
  end

  def test_it_doesnt_find_non_existing_doi
    res = @mds.resolve NON_EXISTING_DOI_1
    assert_instance_of Net::HTTPNotFound, res
  end

  def test_it_doesnt_allow_unauthorised_access
    mds = Datacite::Mds.new authorize: {usr: "unauthorized", pwd: "unauthorized"}, testing: true
    res = mds.resolve EXISTING_DOI
    assert_instance_of Net::HTTPUnauthorized, res

  end

  ### GET (metadata)
  def test_it_gets_metadata_for_existing_doi
    res = @mds.get_metadata EXISTING_DOI
    assert_instance_of Net::HTTPOK, res
  end

  ### GET (DOIs)
  def test_it_gets_all_dois_for_datacentre
    res = @mds.get_all_dois
    assert_instance_of Net::HTTPOK, res
  end


  ### POST (mint a DOI)

  def test_it_wont_mint_doi_without_loaded_metadata
    res = @mds.mint NON_EXISTING_DOI_1, EXISTING_URL
    assert_instance_of Net::HTTPPreconditionFailed, res
  end

  def test_it_mints_doi
    res = @mds.upload_metadata METADATA_1
    assert_instance_of Net::HTTPCreated, res
    assert_match NON_EXISTING_DOI_2, res.body
    res = @mds.mint NON_EXISTING_DOI_2, EXISTING_URL
    assert_instance_of Net::HTTPCreated, res
  end


  ### DELETE (metadata)

  def test_it_deletes_metadata
    res = @mds.upload_metadata METADATA_2
    assert_instance_of Net::HTTPCreated, res

    doc = Nokogiri::XML(METADATA_2)
    doi = doc.css("identifier[identifierType='DOI']").text

    refute_nil doi
    assert_instance_of String, doi
    res = @mds.delete_metadata doi
    assert_instance_of Net::HTTPOK, res
    res = @mds.get_metadata doi
    assert_instance_of Net::HTTPGone, res
  end

  ### non-RESTful operations
  def test_it_detects_malformed_metadata
    assert_raises(ArgumentError) { Datacite::Mds.metadata_valid?MALFORMED_METADATA }
  end

  def test_it_detects_invalid_metadata
    assert_equal Datacite::Mds.metadata_valid?(INVALID_METADATA), false
    assert_equal Datacite::Mds.validation_errors.size, 1
  end


end
