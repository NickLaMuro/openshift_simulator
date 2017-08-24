require "openshift_simulator/server/default_endpoint"
require "openshift_simulator/server/endpoint"

module OpenshiftSimulator
  class Server
    def self.start options = {}
      new(options).start
    end

    def initialize options = {}
      @port          = options[:port]
      @response_dir  = options[:dir]
      @response_file = Pathname.new(options[:cassette_file])
      @app_route_map = {}
      @options       = options
    end

    def start
      Rack::Server.start :app  => build_rack_app,
                         :Port => @port
    end

    private

    def build_rack_app
      setup_response_dir

      # required for scoping issues
      root_dir  = @response_dir
      route_map = @app_route_map

      Rack::Builder.new do
        map "/" do
          run OpenshiftSimulator::DefaultEndpoint.new
        end

        route_map.each do |route, config|
          map route do
            run OpenshiftSimulator::Endpoint.endpoint_for config.dup, root_dir
          end
        end
      end.to_app
    end

    def setup_response_dir
      require 'yaml'
      require 'uri'
      require 'pathname'

      dir = Pathname.new @response_dir

      process_vcr_cassette_in dir

      @app_route_map = Marshal.load(IO.binread(dir.join("__app_route_map")))
    end

    def fetch_token_for http
      if @options.has_key?(:token)
        @options[:token]
      else
        http["request"]["headers"]["Authorization"].detect { |h|
          h.include? "Bearer"
        }.to_s.split(' ').last
      end
    end

    # Process the vcr cassette in a seperate process to avoid bloating the
    # original process with uneccessary memory bloat
    def process_vcr_cassette_in dir
      return if build_cache_link_present_already_expanded?

      pid = fork do
        # Remove existing data
        FileUtils.rm_rf Dir.glob(dir.join("*").to_s)

        app_route_map = {}
        vcr = YAML.load_file @response_file
        vcr["http_interactions"].each do |http|
          request_uri  = URI.parse http["request"]["uri"]
          local_path   = dir.join request_uri.path[1..-1]
          local_path   = local_path.join "index.html" if local_path.basename.to_s == "v1";

          FileUtils.mkdir_p local_path.dirname
          local_path.write http["response"]["body"]["string"]

          app_route_map[request_uri.path.dup] = {
            :response_path => local_path.expand_path.to_s,
            :path          => request_uri.path.dup,
            :method        => http["request"]["method"].upcase,
            :status        => http["response"]["status"],
            :headers       => http["response"]["headers"],
            :token         => fetch_token_for(http)
          }
        end

        # @app_route_map that will be loaded by the main process
        File.write dir.join("__app_route_map"),
                   Marshal.dump(app_route_map),
                   :mode => "wb"

        # Cache check link that will short circut this process if this
        # directory has been setup before
        FileUtils.ln_s @response_file.expand_path, build_cache_link

        vcr = nil
      end
      Process.wait pid
    end

    def build_cache_link
      @build_cache_link ||= Pathname.new(@response_dir).join("__response_file")
    end

    def build_cache_link_present_already_expanded?
      build_cache_link.exist? &&
        File.realpath(build_cache_link.to_s) == @response_file.expand_path.to_s &&
        File.lstat(build_cache_link).mtime > File.stat(@response_file).mtime
    end
  end
end
