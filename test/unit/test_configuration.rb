require 'test_helper'

class TestPackager < Jammit::Packager
end

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

  def test_loading_a_nonexistent_java
    Jammit.instance_variable_set('@checked_java_version', false)
    Jammit.load_configuration('test/config/assets-no-java.yml')
    assert !Jammit.compress_assets
    @compressor = Compressor.new
    # Should not compress js.
    packed = @compressor.compress_js(glob('test/fixtures/src/*.js'))
    assert packed == File.read('test/fixtures/jammed/js_test-uncompressed.js')
    # Nothing should change with jst.
    packed = @compressor.compile_jst(glob('test/fixtures/src/*.jst'))
    assert packed == File.read('test/fixtures/jammed/jst_test.js')
    packed = @compressor.compress_css(glob('test/fixtures/src/*.css'))
    assert packed == File.open('test/fixtures/jammed/css_test-uncompressed.css', 'r:binary') {|f| f.read }
  end

  def test_disabled_compression
    Jammit.load_configuration('test/config/assets-compression-disabled.yml')
    assert !Jammit.compress_assets
    assert !Jammit.gzip_assets
    @compressor = Compressor.new
    # Should not compress js.
    packed = @compressor.compress_js(glob('test/fixtures/src/*.js'))
    assert packed == File.read('test/fixtures/jammed/js_test-uncompressed.js')
    # Nothing should change with jst.
    packed = @compressor.compile_jst(glob('test/fixtures/src/*.jst'))
    assert packed == File.read('test/fixtures/jammed/jst_test.js')
    packed = @compressor.compress_css(glob('test/fixtures/src/*.css'))
    assert packed == File.open('test/fixtures/jammed/css_test-uncompressed.css', 'r:binary') {|f| f.read }
  end

  def test_css_compression
    assert Jammit.compress_assets
    assert Jammit.gzip_assets
    packed = @compressor.compress_css(glob('test/fixtures/src/*.css'))
    assert packed == File.read('test/fixtures/jammed/css_test.css')
  end

  def test_erb_configuration
    Jammit.load_configuration('test/config/assets-erb.yml')
    assert Jammit.compress_assets
    packed = @compressor.compress_css(glob('test/fixtures/src/*.css'))
    assert packed == File.read('test/fixtures/jammed/css_test.css')
  end

  def test_css_configuration
    Jammit.load_configuration('test/config/assets-css.yml')
    packed = Compressor.new.compress_css(glob('test/fixtures/src/*.css'))
    assert packed == File.read('test/fixtures/jammed/css_test-line-break.css')
  end

  def test_javascript_compression
    packed = @compressor.compress_js(glob('test/fixtures/src/*.js'))
    assert packed == File.read('test/fixtures/jammed/js_test.js')
  end

  def test_jst_compilation
    packed = @compressor.compile_jst(glob('test/fixtures/src/*.jst'))
    assert packed == File.read('test/fixtures/jammed/jst_test.js')
  end

  def test_packager
    Jammit.load_configuration('test/config/assets-packager.yml')
    assert_instance_of TestPackager, Jammit.packager
  end

end
