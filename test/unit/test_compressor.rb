require 'test_helper'

class CompressorTest < Test::Unit::TestCase

  def setup
    @compressor = Compressor.new
  end

  def test_javascript_compression
    packed = @compressor.compress_js(glob('test/fixtures/src/*.js'))
    assert packed == File.read('test/fixtures/jammed/js_test.js')
  end

  def test_css_compression
    packed = @compressor.compress_css(glob('test/fixtures/src/*.css'))
    assert packed == File.read('test/fixtures/jammed/css_test.css')
  end

  def test_jst_compilation
    packed = @compressor.compile_jst(glob('test/fixtures/src/*.jst'))
    assert packed == File.read('test/fixtures/jammed/jst_test.js')
  end

end
