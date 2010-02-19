require 'test_helper'

class CompressorTest < Test::Unit::TestCase

  def setup
    @compressor = Compressor.new
  end

  def test_javascript_compression
    packed = @compressor.compress_js(glob('test/fixtures/src/test*.js'))
    assert packed == File.read('test/fixtures/jammed/test.js')
  end

  def test_css_compression
    packed = @compressor.compress_css(glob('test/fixtures/src/*.css'))
    assert packed == File.read('test/fixtures/jammed/test.css')
  end

  def test_jst_compilation
    packed = @compressor.compile_jst(glob('test/fixtures/src/test*.jst'))
    assert packed == File.read('test/fixtures/jammed/templates.jst')
  end

end
