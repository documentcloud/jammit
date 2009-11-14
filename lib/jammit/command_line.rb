require File.expand_path(File.dirname(__FILE__) + '/../jammit')

module Jammit

  # The CommandLine is able to compress, pre-package, and pre-gzip all the
  # assets specified in the configuration file, in order to avoid an initial
  # round of slow requests after a fresh deployment.
  class CommandLine

    BANNER = <<-EOS

Usage: jammit [output-folder]

Compresses all JS, CSS, and JST according to config/assets.yml,
saving the resulting files, along with gzipped versions, to
the output-folder ("public/assets" by default).

    EOS

    # jammit [/path/to/output]
    def initialize
      parse_help_or_version(ARGV[0])
      ensure_configuration_file
      Jammit.packager.precache_all(ARGV[0])
    end

    # There are no real options for 'jammit' yet, just --help and --version.
    def parse_help_or_version(arg)
      if ['-h', '--help'].include? arg
        puts BANNER
        exit
      elsif ['-v', '--version'].include? arg
        puts "Jammit version #{Jammit::VERSION}"
        exit
      end
    end

    # Make sure that we have a readable configuration file.
    def ensure_configuration_file
      config = Jammit::DEFAULT_CONFIG_PATH
      return true if File.exists?(config) && File.readable?(config)
      puts "Could not find the asset configuration file \"#{config}\""
      exit(1)
    end

  end

end