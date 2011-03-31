# Standard Library Dependencies:
require 'uri'
require 'erb'
require 'zlib'
require 'yaml'
require 'base64'
require 'pathname'
require 'fileutils'

# Gem Dependencies:
available_dependencies = []

# Include YUI as the default
require 'yui/compressor'

begin
  require 'closure-compiler'
  available_dependencies << :closure
rescue LoadError
  Jammit.loaded_compressors.delete :closure
  puts "Closure is unavailable."
end
begin
  require 'uglifier'
  available_dependencies << :uglifier
rescue LoadError
  Jammit.loaded_compressors.delete :uglifier
  puts "Uglifier is unavailable."
end

# Load initial configuration before the rest of Jammit.
Jammit.load_configuration(Jammit::DEFAULT_CONFIG_PATH, true) if defined?(Rails)

# Jammit Core:
require 'jammit/uglifier' if Jammit.loaded_compressors.include?( :uglifier )
require 'jammit/compressor'
require 'jammit/packager'

# Jammit Rails Integration:
if defined?(Rails)
  require 'jammit/controller'
  require 'jammit/helper'
  require 'jammit/railtie'
  require 'jammit/routes'
end

