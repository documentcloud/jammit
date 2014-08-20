require 'test_helper'
require 'active_support'
require 'action_pack'
require 'action_controller'
require 'action_controller/base'
require 'action_controller/test_case'
require 'jammit/controller'
require 'jammit/routes'
require 'action_dispatch'

class JammitController
  def self.controller_path
    "jammit"
  end
end

class JammitControllerTest < ActionController::TestCase

  def setup
    # Perform the routing setup that Rails needs to test the controller
    @routes = ::ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get "/package/:package.:extension",
            :to => 'jammit#package', :as => :jammit, :constraints => {
              :extension => /.+/
          }
    end
  end

  def test_package_with_jst
    get(:package, :package => 'jst_test', :extension => 'jst')
    assert_match( /text\/javascript/, @response.headers['Content-Type'] )
    assert_equal( File.read("#{ASSET_ROOT}/fixtures/jammed/jst_test.js"), @response.body )
  end

  def test_package_with_jst_mixed
    get(:package, :package => 'js_test_with_templates', :extension => 'jst')
    assert_match( /text\/javascript/, @response.headers['Content-Type'] )
    assert_equal( File.read("#{ASSET_ROOT}/fixtures/jammed/jst_test.js"), @response.body )
  end

end
