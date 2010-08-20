require 'test_helper'
require 'action_pack'
require 'action_controller'
require 'action_controller/base'
require 'action_controller/test_case'
require 'jammit/controller'
require 'jammit/routes'

class JammitController
  def self.controller_path
    "jammit"
  end
end

class JammitControllerTest < ActionController::TestCase

  CACHE_DIR = '/tmp/jammit_controller_test'

  def setup
    FileUtils.mkdir_p CACHE_DIR
    ActionController::Base.page_cache_directory = CACHE_DIR
    ActionController::Routing::Routes.draw do |map|
      Jammit::Routes.draw(map)
    end
  end

  def teardown
    FileUtils.remove_entry_secure CACHE_DIR
  end

  def test_package_with_jst
    get(:package, :package => 'jst_test', :extension => 'jst')
    assert @response.headers['Content-Type'] =~ /text\/javascript/
    assert @response.body == File.read("#{ASSET_ROOT}/fixtures/jammed/jst_test.js")
  end

  def test_package_with_jst_mixed
    get(:package, :package => 'js_test_with_templates', :extension => 'jst')
    assert @response.headers['Content-Type'] =~ /text\/javascript/
    assert @response.body == File.read("#{ASSET_ROOT}/fixtures/jammed/jst_test.js")
  end

  def test_route_with_jst_diff_ext
    assert_generates('/assets/test.html.mustache', {
      :controller => 'jammit',
      :action => 'package',
      :package => 'test',
      :extension => 'html.mustache'
    })
    assert_recognizes({
      :controller => 'jammit',
      :action => 'package',
      :package => 'test',
      :extension => 'html.mustache'
    }, '/assets/test.html.mustache')
  end

  def test_package_with_jst_diff_ext
    Jammit.reload!
    Jammit.set_template_extension('html.mustache')
    get(:package, :package => 'jst_test_diff_ext', :extension => 'html.mustache')
    assert @response.headers['Content-Type'] =~ /text\/javascript/
    assert @response.body == File.read("#{ASSET_ROOT}/fixtures/jammed/jst_test_diff_ext.js")
  ensure
    Jammit.reload!
  end

end
