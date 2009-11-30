# Standard Library Dependencies:
require 'uri'
require 'zlib'
require 'base64'
require 'pathname'
require 'fileutils'

# Gem Dependencies:
require 'rubygems'
require 'yui/compressor'
require 'closure-compiler'
require 'active_support'

# Load initial configuration before the rest of Jammit.
Jammit.load_configuration(Jammit::DEFAULT_CONFIG_PATH) if defined?(Rails)

# Jammit Core:
require 'jammit/compressor'
require 'jammit/packager'

# Jammit Rails Integration:
if defined?(Rails)
  require 'jammit/controller' # Rails will auto-load 'jammit/helper' for us.
  require 'jammit/routes'
end