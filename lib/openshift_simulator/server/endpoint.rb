require "rack/auth/basic"
require "rack/auth/token"

module OpenshiftSimulator
  class Endpoint
    def self.endpoint_for config, root
      app = new config, root
      if config[:token]
        server_token = config[:token].dup
        validation   = lambda { |token|
          Rack::Utils.secure_compare(server_token, token)
        }

        Rack::Auth::Token.new(app, nil, &validation)
      else
        app
      end
    end

    def initialize config, root
      @config      = config
      @file_server = Rack::File.new(root, headers, nil)
    end

    def call env
      request = Rack::Request.new env
      if request.path == @config[:path] && request.request_method == @config[:method]
        @file_server.serving request, @config[:response_path]
      else
        [ 404, {'Content-Type' => 'text/plain'}, ["Not Found"] ]
      end
    rescue => e
      [ 500, {'Content-Type' => 'text/plain'}, ["Error:  #{e.message}"] ]
    end

    private

    def status_code
      @config[:status]["code"].to_i
    rescue NoMethodError => e
      raise "Invalid status code from VCR Cassette: #{@config.inspect}"
    end

    def headers
      {}.tap do |response_headers|
        Array(@config[:headers]).each do |(header, vals)|
          next if %w[Date Transfer-Encoding].include? header

          response_headers[header] = vals.first
        end
      end
    end
  end
end

