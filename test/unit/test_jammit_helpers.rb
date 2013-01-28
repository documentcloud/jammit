$: << File.expand_path(File.dirname(__FILE__) + "/..") ; require 'test_helper'
require 'action_pack'
require 'action_view'
require 'action_view/base'
require 'action_controller'
require 'action_controller/base'

# fix for ruby 1.9.3 compatibility with rails 2.3.14
MissingSourceFile::REGEXPS << [/^cannot load such file -- (.+)$/i, 1]

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
    Jammit.load_configuration('test/config/assets.yml').reload!
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

  def test_individual_assets_in_development
    Jammit.instance_variable_set(:@package_assets, false)
    assert include_stylesheets(:css_test) == File.read('test/fixtures/tags/css_individual_includes.html')
    assert include_javascripts(:js_test_with_templates) == File.read('test/fixtures/tags/js_individual_includes.html')
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
