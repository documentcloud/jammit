require 'optparse'

module Jammit

  class CommandLine

    BANNER <<-EOS
Usage:
  jammit pack path/to/assets.yml
  Compresses all JS, CSS, and JST according to assets.yml, saving the
  resulting files to the output_folder

  jammit css stylesheet1.css stylesheet2.css

  jammit js script1.js script1.js

  jammit jst template1.jst template2.jst

    EOS

    def initialize

    end