# Standard Library Dependencies:
require 'uri'
require 'erb'
require 'zlib'
require 'yaml'
require 'base64'
require 'pathname'
require 'fileutils'

# Include YUI as the default
require 'yui/compressor'

# Try Closure.
begin
  require 'closure-compiler'
rescue LoadError
  Jammit.compressors.delete :closure
end

# Try Uglifier.
begin
  require 'uglifier'
rescue LoadError
  Jammit.compressors.delete :uglifier
end

# Load initial configuration before the rest of Jammit.
Jammit.load_configuration(Jammit::DEFAULT_CONFIG_PATH, true) if defined?(Rails)

# Jammit Core:
require 'jammit/uglifier' if Jammit.compressors.include? :uglifier
require 'jammit/compressor'
require 'jammit/packager'

# Jammit Rails Integration:
if defined?(Rails)
  require 'jammit/controller'
  require 'jammit/helper'
  require 'jammit/railtie'
  require 'jammit/routes'
end

