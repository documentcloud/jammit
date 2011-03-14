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

  def test_include_stylesheets
    assert include_stylesheets(:css_test) == File.read('test/fixtures/tags/css_includes.html')
  end

  def test_include_stylesheets_with_options
    assert include_stylesheets(:css_test, :media => 'print') == File.read('test/fixtures/tags/css_print.html')
  end

  def test_include_stylesheets_forcing_embed_assets_off
    assert include_stylesheets(:css_test, :embed_assets => false) == File.read('test/fixtures/tags/css_plain_includes.html')
  end

  def test_include_javascripts
    assert include_javascripts(:js_test) == '<script src="/assets/js_test.js?101" type="text/javascript"></script>'
  end

  def test_include_templates
    assert include_javascripts(:jst_test) == '<script src="/assets/jst_test.js?101" type="text/javascript"></script>'
  end

  def test_include_templates_with_diff_ext
    assert include_javascripts(:jst_test_diff_ext) == '<script src="/assets/jst_test_diff_ext.js?101" type="text/javascript"></script>'
  end

  def test_include_javascripts_with_head_js_in_development
    Jammit.instance_variable_set(:@package_assets, false)
    assert_equal File.read('test/fixtures/tags/headjs_with_individual_includes.html').chomp, include_headjs_javascripts(:js_test_with_templates)
  end

  def test_individual_assets_in_development
    Jammit.instance_variable_set(:@package_assets, false)
    assert include_stylesheets(:css_test) == File.read('test/fixtures/tags/css_individual_includes.html')
    assert include_javascripts(:js_test_with_templates) == File.read('test/fixtures/tags/js_individual_includes.html')
    # Test to make sure different extensions don't change things.
    Jammit.reload!
    Jammit.instance_variable_set(:@package_assets, false)
    Jammit.set_template_extension('html.mustache')
    assert include_javascripts(:jst_test_diff_ext) == '<script src="/assets/jst_test_diff_ext.html.mustache?101" type="text/javascript"></script>'
  ensure
    Jammit.reload!
  end

  def test_individual_assets_while_debugging
    @debug = true
    assert include_stylesheets(:css_test) == File.read('test/fixtures/tags/css_individual_includes.html')
    assert include_javascripts(:js_test_with_templates) == File.read('test/fixtures/tags/js_individual_includes.html')
    @debug = false
  end
end
