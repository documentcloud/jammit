# Standard Library Dependencies:
require 'uri'
require 'erb'
require 'zlib'
require 'yaml'
require 'base64'
require 'pathname'
require 'fileutils'

# Try Uglifier.
begin
  require 'uglifier'
  require 'jammit/uglifier'
rescue LoadError
  Jammit.javascript_compressors.delete :uglifier
end

# Try YUI
begin
  require 'yui/compressor'
rescue LoadError
  Jammit.javascript_compressors.delete :yui
  Jammit.css_compressors.delete :yui
end

# Try Closure.
begin
  require 'closure-compiler'
rescue LoadError
  Jammit.javascript_compressors.delete :closure
end

# Try Sass
begin
  require 'sass'
  require 'jammit/sass_compressor'
rescue LoadError
  Jammit.css_compressors.delete :sass
end

# Load initial configuration before the rest of Jammit.
Jammit.load_configuration(Jammit::DEFAULT_CONFIG_PATH, true) if defined?(Rails)

# Jammit Core:
require 'jsmin'
require 'cssmin'
require 'jammit/jsmin_compressor'
require 'jammit/cssmin_compressor'
require 'jammit/compressor'
require 'jammit/packager'

# Jammit Rails Integration:
if defined?(Rails)
  require 'jammit/controller'
  require 'jammit/helper'
  require 'jammit/railtie'
  require 'jammit/routes'
end

# Load user extentions
require 'jammit/extensions'

