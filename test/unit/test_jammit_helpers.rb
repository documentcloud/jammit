require 'test_helper'
require 'action_pack'
require 'action_view'
require 'action_view/base'
require 'action_controller'
require 'action_controller/base'
require 'action_view/test_case'
require 'jammit/controller'
require 'jammit/helper'

class ActionController::Base
  cattr_accessor :asset_host
end

class JammitHelpersTest < ActionView::TestCase
  include ActionView::Helpers::AssetTagHelper
  include Jammit::Helper

  # Rails 3.0 compatibility.
  if defined?(ActionController::Configuration)
    include ActionController::Configuration
    extend ActionController::Configuration::ClassMethods
    def initialize(*args)
      super
      @config = ActiveSupport::OrderedOptions.new
      @config.merge! ActionView::DEFAULT_CONFIG
    end
  end

  def params
    @debug ? {:debug_assets => true} : {}
  end

  def setup
    Rails.env = "pretend_this_isnt_test"
    Jammit.load_configuration('test/config/assets.yml').reload!
  end

  def test_include_stylesheets
    File.write('test/fixtures/tags/css_includes.html', include_stylesheets(:css_test) )
    assert_equal File.read('test/fixtures/tags/css_includes.html'), include_stylesheets(:css_test)
  end

  def test_include_stylesheets_with_options
    assert_equal File.read('test/fixtures/tags/css_print.html'), include_stylesheets(:css_test, :media => 'print')
  end

  def test_include_stylesheets_forcing_embed_assets_off
    assert_equal File.read('test/fixtures/tags/css_plain_includes.html'), include_stylesheets(:css_test, :embed_assets => false)
  end

  def test_include_javascripts
    assert_equal '<script src="/assets/js_test.js"></script>', include_javascripts(:js_test)
  end

  def test_include_templates
    assert_equal '<script src="/assets/jst_test.js"></script>', include_javascripts(:jst_test)
  end

  def test_individual_assets_in_development
    Jammit.instance_variable_set(:@package_assets, false)
    asset = File.read('test/fixtures/tags/css_individual_includes.html')
    assert_equal asset, include_stylesheets(:css_test)
    asset = File.read('test/fixtures/tags/js_individual_includes.html')
    assert_equal asset, include_javascripts(:js_test_with_templates)
  ensure
    Jammit.reload!
  end

  def test_individual_assets_while_debugging
    @debug = true
    asset = File.read('test/fixtures/tags/css_individual_includes.html')
    assert_equal asset, include_stylesheets(:css_test)
    asset = File.read('test/fixtures/tags/js_individual_includes.html')
    assert_equal asset, include_javascripts(:js_test_with_templates)
    @debug = false
  end

end
