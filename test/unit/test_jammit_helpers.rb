require 'test_helper'
require 'action_pack'
require 'action_view'
require 'action_view/base'
require 'action_controller'
require 'action_controller/base'
require 'action_view/test_case'
require 'jammit/helper'

class ActionController::Base
  cattr_accessor :asset_host
end

class JammitHelpersTest < ActionView::TestCase
  include ActionView::Helpers::AssetTagHelper
  include Jammit::Helper

  def test_include_stylesheets
    assert include_stylesheets(:test) == File.read('test/fixtures/tags/css_includes.html')
  end

  def test_include_stylesheets_with_options
    assert include_stylesheets(:test, :media => 'print') == File.read('test/fixtures/tags/css_print.html')
  end

  def test_include_stylesheets_forcing_embed_assets_off
    assert include_stylesheets(:test, :embed_assets => false) == File.read('test/fixtures/tags/css_plain_includes.html')
  end

  def test_include_javascripts
    assert include_javascripts(:test) == '<script src="/assets/test.js?101" type="text/javascript"></script>'
  end

  def test_include_templates
    assert include_templates(:test) == '<script src="/assets/test.jst?101" type="text/javascript"></script>'
  end

  def test_individual_assets_in_development_do
    Jammit.instance_variable_set(:@package_assets, false)
    assert include_stylesheets(:test) == File.read('test/fixtures/tags/css_individual_includes.html')
    Jammit.reload!
  end

end
