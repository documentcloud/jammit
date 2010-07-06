# Standard Library Dependencies:
require 'uri'
require 'erb'
require 'zlib'
require 'base64'
require 'pathname'
require 'fileutils'

require 'yaml'

# Gem Dependencies:
require 'yui/compressor'
require 'closure-compiler'
require 'active_support/core_ext/hash'

# Load initial configuration before the rest of Jammit.
Jammit.load_configuration(Jammit::DEFAULT_CONFIG_PATH) if defined?(Rails)

# Jammit Core:
require 'jammit/compressor'
require 'jammit/packager'

# Jammit Rails Integration:
if defined?(Rails)
  require 'jammit/controller'
  require 'jammit/helper'
  require 'jammit/railtie'
  require 'jammit/routes'
end

