begin
  require "vcr"

  # This is a modified form of code by Adam Grare
  #
  #   https://gist.github.com/agrare/0e47baabcb0d0410b3ad8b77484fd712
  #
  module OpenshiftSimulator
    module Commands
      class Capture
        DEFAULT_OPTS = {
          :host          => "localhost:443",
          :cassette_file => "simulator_requests",
          :open_timeout  => 60,
          :read_timeout  => 60
        }.freeze

        def self.help_text
          "Run a capture on speicifc openshift endpoints to a cassette file"
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

          @opts[:endpoints] = args
        end

        def run
          require_relative "../capture.rb"
          OpenshiftSimulator::Capture.start @opts
        end

        private

        def option_parser
          @optparse ||= OptionParser.new do |opt|
            opt.banner = "Usage: #{File.basename $0} capture [-d|-h|-u|-p|-P|-t] [URL] [ENDPOINTS..]"

            opt.separator ""
            opt.separator self.class.help_text.capitalize
            opt.separator ""
            opt.separator "Options"

            opt.on "-d DIR",   "--dir=DIR",          "The dir to save recordings (default: pwd)",   set_dir
            opt.on "-H HOST",  "--host=HOST",        "The URL/IP of the openshift API",             set_host
            opt.on "-P PORT",  "--port=PORT",        "Server port (default: 443)",                  set_port
            opt.on "-u USER",  "--user=USER",        "The user to make the API requests with",      set_user
            opt.on "-p PASS",  "--pass=PASS",        "The password to make the API requests with",  set_pass
            opt.on "-t TOKEN", "--token=TOKEN",      "The API token to make the API requests with", set_token
            opt.on "-o SEC",   "--open-timeout=SEC", "API Open timeout #{default :open_timeout}",   set_otime
            opt.on "-r SEC",   "--read-timeout=SEC", "API Read timeout #{default :read_timeout}",   set_rtime
            opt.on "-h",       "--help",             "Show this message",                           set_help
          end
        end

        def set_dir
          Proc.new { |dir| @opts[:dir] = dir }
        end

        def set_host
          Proc.new { |host| @opts[:host] = host }
        end

        def set_port
          Proc.new { |port| @opts[:port] = port.to_i }
        end

        def set_user
          Proc.new { |user| @opts[:user] = user }
        end

        def set_pass
          Proc.new { |pass| @opts[:pass] = pass }
        end

        def set_token
          Proc.new { |token| @opts[:token] = token }
        end

        def set_otime
          Proc.new { |open_timeout| @opts[:open_timeout] = open_timeout.to_i }
        end

        def set_rtime
          Proc.new { |read_timeout| @opts[:read_timeout] = read_timeout.to_i }
        end

        def set_help
          Proc.new { @opts[:help] = true }
        end

        def default option
          "(default: #{DEFAULT_OPTS[option]})"
        end
      end
    end
  end
rescue LoadError
  # The vcr gem isn't available, so that needs to be installed
end
