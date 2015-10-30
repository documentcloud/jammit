require 'test_helper'

class BrokenConfigurationTest < Minitest::Test

  def setup
    Jammit.load_configuration('test/config/assets-broken.yml').reload!
    @compressor = Compressor.new
  end

  def test_loading_a_nonexistent_file
    assert_raises(MissingConfiguration) do
      Jammit.load_configuration('nonexistent/assets.yml')
    end
  end
end

class ConfigurationTest < MiniTest::Test
  def test_default_booleans
    Jammit.load_configuration('test/config/assets-default.yml')
    # Default false
    assert !Jammit.embed_assets
    assert !Jammit.mhtml_enabled
    # Default true
    assert Jammit.compress_assets
    assert Jammit.rewrite_relative_paths
    assert Jammit.gzip_assets
    assert Jammit.allow_debugging
  end


  def test_disabled_compression
    Jammit.load_configuration('test/config/assets-compression-disabled.yml')
    assert !Jammit.compress_assets
    assert !Jammit.gzip_assets
    @compressor = Compressor.new
    # Should not compress js.
    packed = @compressor.compress_js(glob('test/fixtures/src/*.js'))
    assert_equal File.read('test/fixtures/jammed/js_test-uncompressed.js'), packed
    # Nothing should change with jst.
    packed = @compressor.compile_jst(glob('test/fixtures/src/*.jst'))
    assert_equal File.read('test/fixtures/jammed/jst_test.js'), packed
    packed = @compressor.compress_css(glob('test/fixtures/src/*.css'))
    assert_equal packed, File.read('test/fixtures/jammed/css_test-uncompressed.css', { encoding: 'UTF-8'})
  end

  def test_css_compression
    Jammit.load_configuration('test/config/assets-css.yml').reload!
    assert Jammit.compress_assets
    assert Jammit.gzip_assets
    packed = Compressor.new.compress_css(glob('test/fixtures/src/*.css'))
    assert_equal packed, File.read('test/fixtures/jammed/css_test-line-break.css')
  end

  def test_erb_configuration
    Jammit.load_configuration('test/config/assets-erb.yml')
    assert Jammit.compress_assets
    packed = Compressor.new.compress_css(glob('test/fixtures/src/*.css'))
    assert_equal packed, File.read('test/fixtures/jammed/css_test.css')
  end

  def test_css_configuration
    Jammit.load_configuration('test/config/assets.yml').reload!
    packed = Compressor.new.compress_css(glob('test/fixtures/src/*.css'))
    assert_equal packed, File.read('test/fixtures/jammed/css_test.css')
  end

  def test_javascript_compression
    Jammit.load_configuration('test/config/assets.yml')
    packed = Compressor.new.compress_js(glob('test/fixtures/src/*.js'))
    assert_equal packed, File.read('test/fixtures/jammed/js_test.js')
  end

  def test_jst_compilation
    Jammit.load_configuration('test/config/assets.yml')
    packed = Compressor.new.compile_jst(glob('test/fixtures/src/*.jst'))
    assert_equal packed, File.read('test/fixtures/jammed/jst_test.js')
  end

  def test_environment_specific_configuration
    Rails.env = 'development'
    Jammit.load_configuration('test/config/assets-environment.yml')

    assert !Jammit.compress_assets # Should override with environment specific configuration
    assert Jammit.gzip_assets # but keep the general configuration

    Rails.env = 'test'
  end

  def test_no_rewrite_relative_paths
    Jammit.load_configuration('test/config/assets-no-rewrite-relative-paths.yml')
    assert !Jammit.rewrite_relative_paths
    packed = Compressor.new.compress_css(glob('test/fixtures/src/*.css'))
    assert_equal packed, File.read('test/fixtures/jammed/css_test-no-rewrite-relative-paths.css')
  end

end
