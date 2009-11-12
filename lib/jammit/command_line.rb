require File.expand_path(File.dirname(__FILE__) + '/../jammit')

module Jammit

  class CommandLine

    BANNER = <<-EOS

Usage: jammit path/to/assets.yml [output-directory]

Compresses all JS, CSS, and JST according to assets.yml, saving the
resulting files, along with gzipped versions, to the output_folder.
The output directory is "public/assets" by default.

    EOS

    def initialize
      @config_path      = ARGV.shift
      @output_directory = ARGV.shift
      parse_help_or_version
      ensure_configuration_file
      compress_all_packages
    end

    def compress_all_packages
      Jammit.load_configuration(@config_path)
      Jammit.packager.precache_all(@output_directory)
    end

    def parse_help_or_version
      if ['-v', '--version'].include? @config_path
        puts "Jammit version #{Jammit::VERSION}"
        exit
      elsif ['-h', '--help'].include? @config_path
        puts BANNER
        exit
      end
    end

    def ensure_configuration_file
      return true if File.exists?(@config_path)
      puts "Could not find the asset configuration file \"#{@config_path}\""
      exit(1)
    end

  end

end