$LOAD_PATH.push File.expand_path(File.dirname(__FILE__))

# @Jammit@ is the central namespace for all Jammit classes, and provides access
# to all of the configuration options.
module Jammit

  VERSION               = "0.3.2"

  ROOT                  = File.expand_path(File.dirname(__FILE__) + '/..')

  ASSET_ROOT            = File.expand_path(defined?(RAILS_ROOT) ? RAILS_ROOT : ".")

  PUBLIC_ROOT           = "#{ASSET_ROOT}/public"

  DEFAULT_CONFIG_PATH   = "#{ASSET_ROOT}/config/assets.yml"

  DEFAULT_PACKAGE_PATH  = "assets"

  DEFAULT_JST_SCRIPT    = "#{ROOT}/lib/jammit/jst.js"

  DEFAULT_JST_COMPILER  = "template"

  AVAILABLE_COMPRESSORS = [:yui, :closure]

  DEFAULT_COMPRESSOR    = :yui

  # Jammit raises a @PackageNotFound@ exception when a non-existent package is
  # requested by a browser -- rendering a 404.
  class PackageNotFound < NameError; end

  # Jammit raises a ConfigurationNotFound exception when you try to load the
  # configuration of an assets.yml file that doesn't exist.
  class ConfigurationNotFound < NameError; end

  # Jammit raises an OutputNotWritable exception if the output directory for
  # cached packages is locked.
  class OutputNotWritable < StandardError; end

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
    conf = config_path && File.exists?(config_path) && YAML.load_file(config_path)
    raise ConfigurationNotFound, "could not find the \"#{config_path}\" configuration file" unless conf
    @config_path            = config_path
    @configuration          = conf = conf.symbolize_keys
    @package_path           = conf[:package_path] || DEFAULT_PACKAGE_PATH
    @embed_images           = conf[:embed_images]
    @mhtml_enabled          = @embed_images && @embed_images != "datauri"
    @compressor_options     = (conf[:compressor_options] || {}).symbolize_keys
    set_javascript_compressor(conf[:javascript_compressor])
    set_package_assets(conf[:package_assets])
    set_template_function(conf[:template_function])
    check_java_version
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

  # Ensure that the JavaScript compressor is a valid choice.
  def self.set_javascript_compressor(value)
    value = value && value.to_sym
    @javascript_compressor = AVAILABLE_COMPRESSORS.include?(value) ? value : DEFAULT_COMPRESSOR
  end

  # Turn asset packaging on or off, depending on configuration and environment.
  def self.set_package_assets(value)
    package_env     = !defined?(Rails) || !Rails.env.development?
    @package_assets = value == true || value.nil? ? package_env :
                      value == 'always'           ? true : false
  end

  # Assign the JST template function, unless explicitly turned off.
  def self.set_template_function(value)
    @template_function = value == true || value.nil? ? DEFAULT_JST_COMPILER :
                         value == false              ? '' : value
    @include_jst_script = @template_function == DEFAULT_JST_COMPILER
  end

  # The YUI Compressor requires Java > 1.4, and Closure requires Java > 1.6.
  def self.check_java_version
    java = @compressor_options[:java] || 'java'
    version = (`#{java} -version 2>&1`)[/\d+\.\d+/]
    disable_compression if !version ||
      (@javascript_compressor == :closure && version < '1.6') ||
      (@javascript_compressor == :yui && version < '1.4')
  end

  # If we don't have a working Java VM, then disable asset compression and
  # complain loudly.
  def self.disable_compression
    @compressor_options[:disabled] = true
    complaint = "Warning: Jammit asset compression disabled -- Java unavailable."
    defined?(Rails) ? Rails.logger.warn(complaint) : STDERR.puts(complaint)
  end

end

require 'jammit/dependencies'
