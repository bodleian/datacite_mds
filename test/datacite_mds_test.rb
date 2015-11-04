require 'test_helper'

class DataciteMdsTest < Minitest::Test

  # tests have been designed to reflect the Datacite MDS API documentation	https://mds.datacite.org/static/apidoc

  NON_EXISTING_DOI_2 = '10.5072/BODLEIAN:xxxORATEST16'
  NON_EXISTING_DOI_1 = '10.5072/BODLEIAN:xxxyy'
  EXISTING_DOI = '10.5287/BODLEIAN:DR26XX70W'
  EXISTING_URL = 'http://ora.ox.ac.uk/objects/uuid:37897aec-0a18-46f6-b6a7-dd8690fa2797'

  METADATA = ( File.read( File.dirname(__FILE__) + '/data_samples/metadata1.xml' ) )

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
    res = @mds.upload_metadata METADATA
    assert_instance_of Net::HTTPCreated, res
    assert_match NON_EXISTING_DOI_2, res.body
    res = @mds.mint NON_EXISTING_DOI_2, EXISTING_URL
    assert_instance_of Net::HTTPCreated, res
  end

end
