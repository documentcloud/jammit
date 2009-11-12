$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

module Jammit

  VERSION = "0.1.0"

  ROOT = File.expand_path(File.dirname(__FILE__) + '/..')

  DEV = defined?(RAILS_ENV) && RAILS_ENV == 'development'

  JST_SCRIPT = File.read(ROOT + '/lib/jammit/jst.js')

  JST_COMPILER = "JST.compile"

  class << self
    attr_reader :configuration, :asset_version, :template_function
  end

  def self.load_configuration(config_path)
    return unless File.exists?(config_path)
    @configuration = YAML.load_file(config_path).symbolize_keys
    @asset_version = @configuration[:version]
    @template_function  = @configuration[:template_function] || JST_COMPILER
  end

  def self.packager
    Thread.current[:jammit_packager] ||= Packager.new
  end

  def self.filename(package, suffix)
    version_part = asset_version ? "v#{asset_version}/" : ''
    "#{version_part}#{package}.#{suffix}"
  end

  class PackageNotFound < NameError
  end

end

require 'zlib'
require 'fileutils'
require 'yui/compressor'
require 'activesupport'

Jammit.load_configuration("#{RAILS_ROOT}/config/assets.yml") if defined?(RAILS_ROOT)

require 'jammit/compressor'
require 'jammit/packager'

if defined?(RAILS_ENV)
  require 'jammit/controller'
  require 'jammit/helper'
  require 'jammit/routes'
  ActionView::Base.send(:include, Jammit::Helper)
end
