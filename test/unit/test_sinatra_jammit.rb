# Skip test_helper
require 'sinatra/base'
require 'sinatra/jammit'
require 'rack/test'

ASSET_ROOT = File.expand_path(File.dirname(__FILE__) + '/..') unless defined?(ASSET_ROOT)

class TestApp < Sinatra::Base
  register Sinatra::Jammit
  set :environment, :test
  set :public, "#{ASSET_ROOT}/public"
end

class BasicSinatraTest < Test::Unit::TestCase 
  include Rack::Test::Methods
  
  def app
    TestApp
  end
  
  def test_package_with_js_sends_js_content_type
    get '/assets/js_test.js'
    
    assert last_response.headers['Content-Type'] =~ /application\/javascript/
  end

  def test_package_with_js_sends_packaged_js
    get '/assets/js_test.js'
    
    assert last_response.body == File.read("#{ASSET_ROOT}/fixtures/jammed/js_test.js")
  end
  
  def test_package_with_jst_sends_js_content_type
    get '/assets/jst_test.jst'
    
    assert last_response.headers['Content-Type'] =~ /application\/javascript/
  end
  
  def test_package_with_jst_sends_packaged_js
    get '/assets/jst_test.jst'
    
    assert last_response.body == File.read("#{ASSET_ROOT}/fixtures/jammed/jst_test.js")
  end
  
  def test_package_with_css_sends_css_content_type
    get '/assets/css_test.css'
    
    assert last_response.headers['Content-Type'] =~ /text\/css/
  end
  
  def test_package_with_css_sends_packaged_css
    get '/assets/css_test.css'
    
    assert last_response.body == File.read("#{ASSET_ROOT}/fixtures/jammed/css_test.css")
  end
  
  def test_should_404_for_invalid_package
    get '/assets/chickens.js'
    
    assert last_response.status == 404
  end
  
  def test_should_not_cache_files
    get '/assets/js_test.js'
    
    assert !File.exists?("#{ASSET_ROOT}/public/cache/assets/js_test.js")
  end
end

class TestAppWithCaching < Sinatra::Base
  register Sinatra::Jammit
  set :environment, :test
  set :cache_enabled, true
  set :cache_output_dir, "#{ASSET_ROOT}/public/cache"
end

class CachingSinatraTest < Test::Unit::TestCase 
  include Rack::Test::Methods
  
  def app
    TestAppWithCaching
  end
  
  def teardown
    FileUtils.rm_rf("#{ASSET_ROOT}/public/cache")
  end
  
  def test_package_should_create_cache
    get '/assets/js_test.js'
    
    assert File.exists?("#{ASSET_ROOT}/public/cache/assets/js_test.js")
  end
  
  def test_package_should_create_gzipped_cache
    get '/assets/js_test.js'
    
    assert File.exists?("#{ASSET_ROOT}/public/cache/assets/js_test.js.gz")
  end
  
end

class TestAppWithFallthroughCaching < Sinatra::Base
  register Sinatra::Jammit
  set :environment, :test
  set :public, "#{ASSET_ROOT}/elsewhere"
  set :cache_enabled, true
end

class FallthroughCachingSinatraTest < Test::Unit::TestCase 
  include Rack::Test::Methods
  
  def app
    TestAppWithFallthroughCaching
  end
  
  def teardown
    FileUtils.rm_rf("#{ASSET_ROOT}/elsewhere")
  end
  
  def test_falls_through_to_public_dir
    get '/assets/js_test.js'
    
    assert File.exists?("#{ASSET_ROOT}/elsewhere/cache/assets/js_test.js.gz")
  end
  
end