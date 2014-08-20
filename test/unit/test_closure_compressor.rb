require 'test_helper'

class ClosureCompressorTest < MiniTest::Test

  def setup
    Jammit.load_configuration('test/config/assets-closure.yml').reload!
    @compressor = Compressor.new
  end

  def teardown
    Jammit.load_configuration('test/config/assets.yml').reload!
  end

  def test_javascript_compression
    packed = @compressor.compress_js(glob('test/fixtures/src/*.js'))
    assert_equal File.read('test/fixtures/jammed/js_test-closure.js'), packed
  end

  def test_jst_compilation
    packed = @compressor.compile_jst(glob('test/fixtures/src/*.jst'))
    assert_equal File.read('test/fixtures/jammed/jst_test.js'), packed
  end

end
