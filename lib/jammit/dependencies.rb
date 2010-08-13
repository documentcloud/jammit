# Standard Library Dependencies:
require 'uri'
require 'erb'
require 'zlib'
require 'yaml'
require 'base64'
require 'pathname'
require 'fileutils'

# Gem Dependencies:
require 'yui/compressor'
require 'closure-compiler'

# Load initial configuration before the rest of Jammit.
Jammit.load_configuration(Jammit::DEFAULT_CONFIG_PATH)

# Jammit Core:
require 'jammit/compressor'
require 'jammit/packager'
require 'jammit/helper'

# Jammit Rails Integration:
if defined?(Rails)
  require 'jammit/controller'
  require 'jammit/railtie'
  require 'jammit/routes'
end