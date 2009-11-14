$LOAD_PATH.push File.expand_path(File.dirname(__FILE__))

module Jammit

  VERSION = "0.1.0" # Keep in sync with jammit.gemspec's version.

  ROOT = File.expand_path(File.dirname(__FILE__) + '/..')

  DEFAULT_CONFIG_PATH  = "config/assets.yml"

  DEFAULT_JST_SCRIPT   = "#{ROOT}/lib/jammit/jst.js"

  DEFAULT_JST_COMPILER = "JST.compile"

  class PackageNotFound < NameError; end

  class << self
    attr_reader :configuration, :template_function, :embed_images
  end

  # Load (or reload) the complete asset configuration from the specified path.
  def self.load_configuration(config_path)
    return unless File.exists?(config_path)
    @config_path        = config_path
    @configuration      = YAML.load_file(@config_path).symbolize_keys
    @template_function  = @configuration[:template_function] || DEFAULT_JST_COMPILER
    @embed_images       = !!@configuration[:embed_images]
    @force_packaging    = !!@configuration[:force_packaging]
  end

  # Force a reload by resetting the Packager and reloading the configuration.
  def self.reload!
    Thread.current[:jammit_packager] = nil
    load_configuration(@config_path)
  end

  # Keep a global reference to a Packager, to avoid recomputing asset lists.
  def self.packager
    Thread.current[:jammit_packager] ||= Packager.new
  end

  # Jammit packages all assets unless we're running in development mode.
  def self.package_assets?
    @dev_env ||= defined?(RAILS_ENV) && RAILS_ENV == 'development'
    @force_packaging || !@dev_env
  end

  # We include the JST compilation function unless overridden.
  def self.include_jst_compiler?
    Jammit.template_function == DEFAULT_JST_COMPILER
  end

  # Generate the filename for a version of a given package.
  def self.filename(package, extension, suffix=nil)
    suffix_part  = suffix ? "-#{suffix}" : ''
    "#{package}#{suffix_part}.#{extension}"
  end

  # Generate the rooted URL to the packaged asset.
  def self.asset_url(package, extension, suffix=nil, mtime=nil)
    timestamp = mtime ? "?#{mtime.to_i}" : ''
    "/assets/#{filename(package, extension, suffix)}#{timestamp}"
  end

end

# Standard Library Dependencies:
require 'zlib'
require 'base64'
require 'fileutils'

# Gem Dependencies:
require 'rubygems'
require 'yui/compressor'
require 'activesupport'

Jammit.load_configuration(Jammit::DEFAULT_CONFIG_PATH)

# Jammit Core:
require 'jammit/compressor'
require 'jammit/packager'

# Jammit Rails Integration:
if defined?(RAILS_ENV)
  require 'jammit/controller' # Rails will auto-load 'jammit/helper' for us.
  require 'jammit/routes'
end
