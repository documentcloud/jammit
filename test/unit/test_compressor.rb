require 'test_helper'

class CompressorTest < Test::Unit::TestCase

  def setup
    Jammit.load_configuration('test/config/assets.yml')
    @compressor = Compressor.new
  end

  def test_javascript_compression
    packed   = @compressor.compress_js(glob('test/fixtures/src/*.js'))
    expected = File.read('test/fixtures/jammed/js_test.js')
    assert packed == expected, "packed: #{packed}\nexpected: #{expected}"
  end

  def test_css_compression
    packed = @compressor.compress_css(glob('test/fixtures/src/*.css'))
    expected = File.read('test/fixtures/jammed/css_test.css')
    assert packed == expected, "packed: #{packed}\nexpected: #{expected}"
  end

  def test_jst_compilation
    packed = @compressor.compile_jst(glob('test/fixtures/src/*.jst'))
    expected = File.read('test/fixtures/jammed/jst_test.js')
    assert packed == expected, "packed: #{packed}\nexpected: #{expected}"
  end

end
