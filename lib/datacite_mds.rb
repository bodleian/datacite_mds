require "datacite_mds/version"
require 'net/http'
require 'openssl'

module Datacite

  ENDPOINT = 'https://mds.datacite.org/'
  RESOURCES = { doi: '/doi', metadata: '/metadata', media: '/media' }


  # Wraps up Mds functionality wihin an object
  #
  # @author Fred Heath
  # @abstract
  # @since 0.1.0
  # @attr [String] username the Datacentre's authorised username
  # @attr [String] passwd the Datacentre's authorised password
  # @attr [Boolean] test_mode indicates whether to make APi calls
  # 	in test mode
  # @attr [URI] uri the object wrapping up the Datacite Endpoint
  # @attr [Net::HTTP] http the object wrapping up the http 
  # 	connection to Datacite Endpoint
  class Mds

    # creates a new Mds object, passing an options hash
    #
    # @param options [Hash] the options to create an Mds objects with.
    # @option options [Hash] :authorize Authorization includes two keys
    # 	:usr [String], :pwd [String]
    # @option options [String] :test_mode If true, all API calls to
    # 	Datacite will occur in test mode
    #
    # @note If :authorize is not passed as an option , then the method
    # 	will look for the usrname and password in environment variables
    # 	DATACITE_USR and DATACITE_PWD.
    #
    def initialize(**options)
      if options[:authorize]
        @username = options[:authorize][:usr]
        @passwd = options[:authorize][:pwd]
      else
        @username = ENV['DATACITE_USR']
        @passwd = ENV['DATACITE_PWD']
      end
      @test_mode = options[:testing] ? '?testMode=true' : ''
      @uri = URI.parse(ENDPOINT)

    end

    # Returns a url associated with a given DOI
    # @param doi [String] a Data Object identifier
    # @return [Net::HTTPResponse] Succesful operation will
    # 	return HTTPOK and the response body will contain
    # 	the URL (String) representing the dataset.
    def resolve(doi)
      @uri.path = RESOURCES[:doi] + '/' + doi
      @http = Net::HTTP.new(@uri.host, @uri.port)
      request = Net::HTTP::Get.new(@uri.request_uri)
      call_datacite(request)
    end

    # Returns a list of all DOIs for the requesting datacentre
    # @return [Net::HTTPResponse] Succesful operation will
    # 	return HTTPOK and the response body will contain
    # 	a list (String) of all relevant DOIs.
    # @note There is no guaranteed order in the list of DOIs
    def get_all_dois
      @uri.path = RESOURCES[:doi]
      @http = Net::HTTP.new(@uri.host, @uri.port)
      request = Net::HTTP::Get.new(@uri.request_uri)
      call_datacite(request)
    end

    # Will mint new DOI if specified DOI doesn't exist. This method
    # will attempt to update URL if you specify existing DOI.
    # Standard domains and quota restrictions check will be
    # performed by Datacite.
    # @param doi [String] a Data Object Identifier
    # @param url [String] the dataset's location
    # @return [Net::HTTPResponse] Succesful operation will
    # 	return HTTPCreated and the response body will
    # 	provide a short explanation of the status code.
    def mint(doi, url)
      @uri.path = RESOURCES[:doi]
      @http = Net::HTTP.new(@uri.host, @uri.port)

      request = Net::HTTP::Post.new(@uri.request_uri)
      @uri.query = @test_mode unless @test_mode.empty?

      request.content_type = 'text/plain'
      request.set_form_data({doi: doi, url: url})

      call_datacite(request)
    end

    # Stores new version of metadata.
    # @param xml_string [String] xml conforming to
    # 	https://schema.datacite.org/
    # @return [Net::HTTPResponse] Succesful operation will
    # 	return HTTPCreated and the response body will
    # 	provide a short explanation of the status code.
    def upload_metadata(xml_string)
      @uri.path = RESOURCES[:metadata]
      @http = Net::HTTP.new(@uri.host, @uri.port)

      @uri.query = @test_mode unless @test_mode.empty?
      request = Net::HTTP::Post.new(@uri.request_uri)
      request.content_type = 'application/xml'
      request.body = xml_string
      call_datacite(request)
    end


    # Returns the most recent version of metadata
    # associated with the DOI.
    # @param doi [String] a Data Object identifier
    # @return [Net::HTTPResponse] Succesful operation will
    # 	return HTTPOK and the response body will consist
    # 	of XML representing a dataset's metadata.
    def get_metadata(doi)
      @uri.path = RESOURCES[:metadata] + '/' + doi
      @http = Net::HTTP.new(@uri.host, @uri.port)
      request = Net::HTTP::Get.new(@uri.request_uri)
      call_datacite(request)
    end

    private

    # Executes an http request, allowing for redirects (3xx codes)
    # @private
    # @param request [Net::HTTPRequest] the request
    # @param request_limit [FixNum] the number of times to keep
    # 	requesting after each redirect
    # @return [Net::HTTPResponse] the response
    def fetch(request, http, request_limit = 5)
      r = http.request(request)

      if r.instance_of? Net::HTTPRedirection
        raise "Max number of redirects reached" if request_limit <= 0
        r = fetch(URI.parse(r.header['location']), request_limit - 1)
      end
      r
    end

    # Sets SSL options on Http object
    # @private
    # @note this settings are required in order to use the Datacite
    # 	API
    def set_security
      @http.use_ssl = true
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end


    # Will add authorization info to the request, if any exists.
    # @private
    # @param request_obj [Net::HTTPRequest] the request
    def set_authorization(request_obj)
      request_obj.basic_auth(@username, @passwd) if (@username && @passwd)
    end

    # Sets security and authorization settings and then executes
    # the http request.
    # @private
    # @param request [Net::HTTPRequest] the request
    # @return [Net::HTTPResponse] the response
    def call_datacite(request)
      set_security
      set_authorization(request)
      fetch(request, @http)
    end

  end
end
