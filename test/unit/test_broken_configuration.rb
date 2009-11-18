require 'test_helper'

class BrokenConfigurationTest < Test::Unit::TestCase

  def setup
    Jammit.load_configuration('test/config/assets-broken.yml').reload!
    @compressor = Compressor.new
  end

  def teardown
    Jammit.load_configuration('test/config/assets.yml').reload!
  end

  def test_loading_a_nonexistent_file
    assert_raises(ConfigurationNotFound) do
      Jammit.load_configuration('nonexistent/assets.yml')
    end
  end

  def test_css_compression
    packed = @compressor.compress_css(Dir['test/fixtures/src/*.css'])
    assert packed == File.read('test/fixtures/jammed/test.css')
  end

  def test_javascript_compression
    packed = @compressor.compress_js(Dir['test/fixtures/src/test*.js'])
    assert packed == File.read('test/fixtures/jammed/test.js')
  end

  def test_jst_compilation
    packed = @compressor.compile_jst(Dir['test/fixtures/src/test*.jst'])
    assert packed == File.read('test/fixtures/jammed/test.jst')
  end

end
