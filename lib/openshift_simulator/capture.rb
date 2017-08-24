require "uri"
require "net/http"

module OpenshiftSimulator
  class Capture
    BasicAuthEncorder = Class.new.tap do |encoder|
      # includes the basic_encode method, which we will use publically via this
      # models encode class method.  Kinda a hack... sue me...
      encoder.extend Net::HTTPHeader

      def encoder.encode user, pass
        basic_encode user, pass
      end
    end

    def self.start options = {}
      new(options).start
    end

    def initialize options = {}
      @options = options
    end

    def start
      configure_vcr
      capture
    end

    private

    def capture
      VCR.use_cassette(@options[:cassette_file], :record => :all) do
        make_requests
      end
    end

    def configure_vcr
      VCR.configure do |config|
        config.cassette_library_dir = @options[:dir] || Dir.pwd
        config.hook_into :webmock
      end
    end

    def make_requests
      @options[:endpoints].each do |endpoint|
        res = http.request_get endpoint, headers
      end
    ensure
      # close the http connection we made
      http.finish
    end

    def headers
      @headers ||= {}.tap do |headers|
        if @options[:token]
          headers["authorization"] = "Bearer #{@options[:token].strip}"
        elsif @options[:user] && @options[:pass]
          user, pass = [@options[:user], @options[:pass]]
          headers["authorization"] = BasicAuthEncorder.encode user, pass
        end
      end
    end

    def http
      @http ||= Net::HTTP.start openshift_uri.hostname,
                                openshift_uri.port,
                                :use_ssl      => openshift_uri.scheme == "https",
                                :open_timeout => @options[:open_timeout],
                                :read_timeout => @options[:read_timeout]
    end

    def openshift_uri
      @openshift_uri ||= begin
        uri      = URI.parse config_host
        uri.port = @options[:port] if @options[:port]

        uri
      end
    end

    def config_host
      host = @options[:host].dup
      host = "https://#{host}" unless host.match /^https?:\/\//
      host
    end
  end
end
