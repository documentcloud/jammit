$LOAD_PATH.push File.expand_path(File.dirname(__FILE__))

module Jammit

  VERSION = "0.1.0" # Keep in sync with jammit.gemspec's version.

  ROOT = File.expand_path(File.dirname(__FILE__) + '/..')

  DEFAULT_CONFIG_PATH  = "config/assets.yml"

  DEFAULT_PACKAGE_PATH = "assets"

  DEFAULT_JST_SCRIPT   = "#{ROOT}/lib/jammit/jst.js"

  DEFAULT_JST_COMPILER = "template"

  class PackageNotFound < NameError; end

  class << self
    # Configuration reader attributes.
    attr_reader :configuration, :template_function, :embed_images, :package_path,
                :package_assets, :mhtml_enabled, :include_jst_script
  end

  # The minimal required configuration.
  @configuration = {}
  @package_path  = DEFAULT_PACKAGE_PATH

  # Load (or reload) the complete asset configuration from the specified path.
  def self.load_configuration(config_path)
    return unless config_path && File.exists?(config_path)
    @config_path        = config_path
    @configuration      = conf = YAML.load_file(@config_path).symbolize_keys
    @template_function  = conf[:template_function] || DEFAULT_JST_COMPILER
    @package_path       = conf[:package_path] || DEFAULT_PACKAGE_PATH
    @embed_images       = conf[:embed_images]
    @mhtml_enabled      = @embed_images && @embed_images != "datauri"
    @include_jst_script = @template_function == DEFAULT_JST_COMPILER
    @package_assets     = case conf[:package_assets]
      when 'always' then true
      when false    then false
      when true     then !defined?(RAILS_ENV) || RAILS_ENV != 'development'
    end
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

  # Generate the filename for a version of a given package.
  def self.filename(package, extension, suffix=nil)
    suffix_part  = suffix ? "-#{suffix}" : ''
    "#{package}#{suffix_part}.#{extension}"
  end

  # Generate the rooted URL to the packaged asset.
  def self.asset_url(package, extension, suffix=nil, mtime=nil)
    timestamp = mtime ? "?#{mtime.to_i}" : ''
    "/#{package_path}/#{filename(package, extension, suffix)}#{timestamp}"
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
