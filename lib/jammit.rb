$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

module Jammit
  
  VERSION = "0.1.0"
  
  ROOT = File.expand_path(File.dirname(__FILE__) + '/..')
  
  DEV = RAILS_ENV == 'development'
  
  JST_SCRIPT = File.read(ROOT + '/lib/jammit/jst.js')
  
  def self.load_configuration
    YAML.load_file("#{RAILS_ROOT}/config/assets.yml")
  end
  
  def self.packager
    @packager ||= Packager.new
  end
  
  ASSET_CONFIG = load_configuration
  
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
