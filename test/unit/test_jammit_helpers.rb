require 'test_helper'
require 'action_controller'
require 'action_view'
require 'action_view/test_case'
require 'jammit/helper'

class ActionController::Base
  cattr_accessor :asset_host
end

class JammitHelpersTest < ActionView::TestCase
  include ActionView::Helpers::AssetTagHelper
  include Jammit::Helper

  def test_include_stylesheets
    assert include_stylesheets(:test) == File.read('fixtures/tags/css_includes.html')
  end

  def test_include_javascripts
    assert include_javascripts(:test) == '<script src="/assets/test.js" type="text/javascript"></script>'
  end

  def test_include_templates
    assert include_templates(:test) == '<script src="/assets/test.jst" type="text/javascript"></script>'
  end

  def test_individual_assets_in_development_do
    Jammit.instance_variable_set(:@package_assets, false)
    assert include_stylesheets(:test) == File.read('fixtures/tags/css_individual_includes.html')
    Jammit.reload!
  end

end
