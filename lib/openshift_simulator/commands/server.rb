begin
  require "rack"

  module OpenshiftSimulator
    module Commands
      class Server
        DEFAULT_OPTS = {
          :dir  => "./tmp/openshift_simulator",
          :port => 8888
        }.freeze

        def self.cmd_name
          "serve(r)"
        end

        def self.help_text
          "Run a openshift simulator server for a given cassette file"
        end

        def self.run args
          new(args).run
        end

        def initialize args
          @opts = DEFAULT_OPTS.dup
          option_parser.parse! args

          if @opts[:help]
            puts @optparse; exit
          end

          @opts[:cassette_file] = args.first
        end

        def run
          require_relative "../server.rb"
          OpenshiftSimulator::Server.start @opts
        end

        private

        def option_parser
          @optparse ||= OptionParser.new do |opt|
            opt.banner = "Usage: #{File.basename $0} serve(r) [-d|-P] CASSETTE_FILE"

            opt.separator ""
            opt.separator self.class.help_text.capitalize
            opt.separator ""
            opt.separator "Options"

            opt.on "-d DIR",   "--dir=DIR",     "API response dir #{default :dir}", set_dir
            opt.on "-P PORT",  "--port=PORT",   "Server port #{default :port}",     set_port
            opt.on "-t TOKEN", "--token=TOKEN", "Global token for all endpoints",   set_token
            opt.on             "--no-token",    "No token required for endpoints",  no_token
            opt.on "-h",       "--help",        "Show this message",                set_help
          end
        end

        def set_dir
          Proc.new { |dir| @opts[:dir] = dir }
        end

        def set_port
          Proc.new { |port| @opts[:port] = port.to_i }
        end

        def set_help
          Proc.new { @opts[:help] = true }
        end

        def set_token
          Proc.new { |token| @opts[:token] = token }
        end

        def no_token
          Proc.new { @opts[:token] = nil }
        end

        def default option
          "(default: #{DEFAULT_OPTS[option]})"
        end
      end
    end
  end
rescue LoadError
  # The rack gem isn't available, so that needs to be installed
end
