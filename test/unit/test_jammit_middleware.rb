require 'test_helper'
require 'sinatra'
require 'jammit/middleware'
require 'rack/test'

set :environment, :test

class TestApp < Sinatra::Application
  use Jammit::Middleware
end

class JammitMiddlewareTest < Test::Unit::TestCase 
  include Rack::Test::Methods
  
  def app
    TestApp
  end
  
  def test_package_with_js
    get '/assets/js_test.js'
    assert last_response.headers['Content-Type'] =~ /application\/javascript/
    assert last_response.body == File.read("#{ASSET_ROOT}/fixtures/jammed/js_test.js")
  end
  
  def test_package_with_jst
    get '/assets/jst_test.jst'
    assert last_response.headers['Content-Type'] =~ /application\/javascript/
    assert last_response.body == File.read("#{ASSET_ROOT}/fixtures/jammed/jst_test.js")
  end
  
  def test_package_with_css
    get '/assets/css_test.css'
    assert last_response.headers['Content-Type'] =~ /text\/css/
    assert last_response.body == File.read("#{ASSET_ROOT}/fixtures/jammed/css_test.css")
  end
  
end