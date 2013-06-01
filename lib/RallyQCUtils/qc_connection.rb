require "httpclient"
require "nori"
require "base64"
require "nokogiri"

module RallyQCUtils

  class QCConnection

    QC_HEADER = { 'Accept' => 'application/xml', 'Content-Type' => 'application/xml'}

    def initialize(config = {}, logger = nil)
      @debug        = config[:debug]
      @logger       = logger
      @qc_url       = "http://#{config[:url]}/qcbin"
      @qc_user      = config[:qc_user]
      @qc_password  = config[:qc_password]
      @artifact_type = config[:artifact_type]
      @qc_client = HTTPClient.new
      @qc_client.debug_dev= STDOUT

      @xml_parser = Nori.new(:parser => :nokogiri)
    end

    #===================================================================================

    def gather_qc_info

      begin
        authenticate(@qc_url)
        domains = get_domains
        domains.each do |domain|
          domain[:projects] = get_projects(domain[:name])
        end
      rescue Exception => ex
        raise ex
      ensure
        logout(@qc_url)
      end

      domains
    end

    def get_domains
      domains = []
      qc_response = send_request("#{@qc_url}/rest/domains", {:method => :get})
      qc_response["Domains"]["Domain"].each do |domain|
        domains.push({:name => domain["@Name"]})
      end
      domains
    end

    def get_projects(domain)
      qc_response = send_request("#{@qc_url.to_s}/rest/domains/#{domain.to_s}/projects", {:method => :get})
      projects = []
      puts "projects is #{qc_response}"
      qc_response["Projects"]["Project"].each do |project|
        projects.push({:name => project["@Name"]})
      end
      projects
    end


    #===================================================================================

    #Client sends a valid Basic Authorization header to the authentication point.
    #    GET /qcbin/authentication-point/authenticate
    #    Authorization: Basic ABCDE123
    #    Server validates the Basic Authorization headers, creates a new LW-SSO token and returns it as LWSSO_COOKIE_KEY.
    #    HTTP/1.1 200 OK
    #    Set-Cookie: LWSSO_COOKIE_KEY={cookie}
    #The application can now access data and services using the token. At the end of the session, log off to discard the token.
    def authenticate(qc_base_url)
      begin
        uri = "#{qc_base_url}/authentication-point/authenticate"
        auth_string = make_auth_string
        headers = { :Authorization => auth_string }
        response = send_request(uri, {:header => headers})
          #puts "auth response is #{response.inspect}"

      rescue Exception => ex
        puts "Exception raised in authenticate #{ex.message}"
      end
    end

    #hit qcbin/authentication-point/logout
    def logout(qc_base_url)
      begin
        uri = "#{qc_base_url}//authentication-point/logout"
        send_request(uri, {:method => :get})
      rescue Exception => ex
        puts "Exception raised #{ex.message}"
      end
    end

    def send_request(uri, args = {}, object = {})
      method = args[:method] || :get
      req_args = {}

      uri = URI.escape(uri)
      headers = QC_HEADER
      headers.merge!(args[:header]) if args[:header]

      if ((method == :post) || (method == :put)) && (object.keys.length > 0)
        xml_fields = entity_to_xml(object[:type], object[:fields])
        req_args[:body] = xml_fields
      end
      req_args[:header] = headers

      begin
        log_info("QC API calling #{method} - #{uri} with #{req_args}\n With cookies: #{@qc_client.cookie_manager.cookies}")
        response = @qc_client.request(method, uri, req_args)
      rescue Exception => ex
        msg = "QCAPI: - rescued exception - #{ex.message} on request to #{uri}"
        log_info(msg)
        raise StandardError, msg
      end

      log_info("QCAPI response was - #{response.inspect}")
      log_info("QCAPI response xml was - #{response.body}")
      if response.status_code > 299
        msg = "QCAPI - HTTP-#{response.status_code} on request - #{uri}."
        msg << "\nResponse was: #{response.body}"
        raise StandardError, msg
      end

      return parse_xml(response.body)
    end

    def parse_xml(response)
      #Nokogiri::XML(response, nil, nil, Nokogiri::XML::ParseOptions::NOBLANKS)
      @xml_parser.parse(response)
    end

    #===========================================================================================



    def check_domain
      qc_response = send_request("#{@qc_url}/rest/domains", {:method => :get})
      return false if qc_response.nil?
      puts "looking for domain #{@domain} in #{qc_response.inspect}" if @debug
      found = false
      qc_response["Domains"]["Domain"].each do |domain|
        if @domain == domain["@Name"]
          found = true
          break
        end
      end
      if !found
        msg = "Error - #{@domain} is not a valid QC Domain"
        raise StandardError, msg
      end
      true
    end

    def check_project
      qc_response = send_request("#{@qc_url.to_s}/rest/domains/#{@domain.to_s}/projects", {:method => :get})
      return false if qc_response.nil?
      found = false
      puts "checking projects for #{@domain} for #{@project} in #{qc_response.inspect}" if @debug
      qc_response["Projects"]["Project"].each do |project|
        if @project == project["@Name"]
          found = true
          break
        end
      end
      if !found
        msg = "Error - #{@project} is not a valid QC Project for #{@domain}"
        raise StandardError, msg
      end
      true
    end


    private

    #qc rest api expects user:password base64 encoded in header
    def make_auth_string
      userpass = "#{@qc_user}:#{@qc_password}"
      enc_userp = Base64.encode64(userpass)
      "Basic #{enc_userp}".strip
    end

    def log_info(message)
      return unless @debug
      puts message if @logger.nil?
      @logger.debug(message) unless @logger.nil?
    end

    def base_url_domain_proj(domain, project)
      "#{@qc_url.to_s}/rest/domains/#{domain}/projects/#{project}"
    end


  end

end
