module OpenshiftSimulator
  module Commands
    class Help
      def self.help
        help_text = ["Usage: #{File.basename $0} [options] args...", ""]

        command_files  = Dir["#{File.dirname __FILE__}/*"].sort
        available_cmds = command_files.map do |command_file|
          begin
            require command_file

            cmd   = File.basename(command_file, ".*")
            klass = OpenshiftSimulator::Commands.const_get(cmd.capitalize)

            cmd   = klass.cmd_name if klass.respond_to? :cmd_name
            help  = klass.help_text

            [cmd, help]
          rescue NameError
            # The class isn't defined, so move on
            #
            # This can be caused by a dependent gem not being installed, so
            # allow the rest of the commands to still function that don't
            # require that dependency.
          end

        end.compact

        ljust_length = available_cmds.map {|(cmd, _)| cmd.length}.max
        available_cmds.each do |(cmd, help)|
          help_text << "    #{cmd.ljust ljust_length}  #{help}"
        end

        puts help_text.join("\n")
      end

      def self.help_text
        "show this help or the help for a subcommand"
      end
    end

    def self.help
      Help.help
    end
  end
end

