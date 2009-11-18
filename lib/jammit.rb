$LOAD_PATH.push File.expand_path(File.dirname(__FILE__))

# @Jammit@ is the central namespace for all Jammit classes, and provides access
# to all of the configuration options.
module Jammit

  VERSION = "0.2.0"

  ROOT = File.expand_path(File.dirname(__FILE__) + '/..')

  DEFAULT_CONFIG_PATH  = "config/assets.yml"

  DEFAULT_PACKAGE_PATH = "assets"

  DEFAULT_JST_SCRIPT   = "#{ROOT}/lib/jammit/jst.js"

  DEFAULT_JST_COMPILER = "template"

  DEFAULT_COMPRESSOR   = :yui

  # Jammit raises a @PackageNotFound@ exception when a non-existent package is
  # requested by a browser -- rendering a 404.
  class PackageNotFound < NameError; end

  class << self
    attr_reader :configuration, :template_function, :embed_images, :package_path,
                :package_assets, :mhtml_enabled, :include_jst_script,
                :javascript_compressor, :compressor_options
  end

  # The minimal required configuration.
  @configuration = {}
  @package_path  = DEFAULT_PACKAGE_PATH

  # Load the complete asset configuration from the specified @config_path@.
  def self.load_configuration(config_path)
    return unless config_path && File.exists?(config_path)
    @config_path            = config_path
    @configuration          = conf = YAML.load_file(@config_path).symbolize_keys
    @package_path           = conf[:package_path] || DEFAULT_PACKAGE_PATH
    @embed_images           = conf[:embed_images]
    @mhtml_enabled          = @embed_images && @embed_images != "datauri"
    @javascript_compressor  = (conf[:javascript_compressor] || DEFAULT_COMPRESSOR).to_sym
    @compressor_options     = conf[:compressor_options] || {}
    set_package_assets(conf[:package_assets])
    set_template_function(conf[:template_function])
    self
  end

  # Force a reload by resetting the Packager and reloading the configuration.
  # In development, this will be called as a before_filter before every request.
  def self.reload!
    Thread.current[:jammit_packager] = nil
    load_configuration(@config_path)
  end

  # Keep a global (thread-local) reference to a @Jammit::Packager@, to avoid
  # recomputing asset lists unnecessarily.
  def self.packager
    Thread.current[:jammit_packager] ||= Packager.new
  end

  # Generate the base filename for a version of a given package.
  def self.filename(package, extension, suffix=nil)
    suffix_part  = suffix ? "-#{suffix}" : ''
    "#{package}#{suffix_part}.#{extension}"
  end

  # Generates the server-absolute URL to an asset package.
  def self.asset_url(package, extension, suffix=nil, mtime=nil)
    timestamp = mtime ? "?#{mtime.to_i}" : ''
    "/#{package_path}/#{filename(package, extension, suffix)}#{timestamp}"
  end


  private

  def self.set_package_assets(value)
    package_env     = !defined?(RAILS_ENV) || RAILS_ENV != 'development'
    @package_assets = case value
    when 'always'     then true
    when false        then false
    when true         then package_env
    when nil          then package_env
    end
  end

  def self.set_template_function(value)
    @template_function = case value
    when false then ''
    when true  then DEFAULT_JST_COMPILER
    when nil   then DEFAULT_JST_COMPILER
    else            value
    end
    @include_jst_script = @template_function == DEFAULT_JST_COMPILER
  end

end

# Standard Library Dependencies:
require 'zlib'
require 'base64'
require 'pathname'
require 'fileutils'

# Gem Dependencies:
require 'rubygems'
require 'yui/compressor'
require 'closure-compiler'
require 'activesupport'

# Load initial configuration before the rest of Jammit.
Jammit.load_configuration(Jammit::DEFAULT_CONFIG_PATH)

# Jammit Core:
require 'jammit/compressor'
require 'jammit/packager'

# Jammit Rails Integration:
if defined?(RAILS_ENV)
  require 'jammit/controller' # Rails will auto-load 'jammit/helper' for us.
  require 'jammit/routes'
end
