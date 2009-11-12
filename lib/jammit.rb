$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

module Jammit

  VERSION = "0.1.0"

  ROOT = File.expand_path(File.dirname(__FILE__) + '/..')

  DEV = RAILS_ENV == 'development'

  JST_SCRIPT = File.read(ROOT + '/lib/jammit/jst.js')

  JST_COMPILER = "JST.compile"

  def self.load_configuration
    YAML.load_file("#{RAILS_ROOT}/config/assets.yml").symbolize_keys
  end

  ASSET_CONFIG = load_configuration

  def self.packager
    @packager ||= Packager.new
  end

  def self.asset_version
    ASSET_CONFIG[:version]
  end

  def self.jst_compiler
    ASSET_CONFIG[:jst_compiler] || JST_COMPILER
  end

  class PackageNotFound < NameError
  end

end

require 'yui/compressor'
require 'jammit/controller'
require 'jammit/compressor'
require 'jammit/helper'
require 'jammit/packager'
require 'jammit/routes'

ActionView::Base.send(:include, Jammit::Helper)
