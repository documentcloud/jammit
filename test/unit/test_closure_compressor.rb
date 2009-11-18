require 'test_helper'

class ClosureCompressorTest < Test::Unit::TestCase

  def setup
    Jammit.load_configuration('test/config/assets-closure.yml').reload!
    @compressor = Compressor.new
  end

  def teardown
    Jammit.load_configuration('test/config/assets.yml').reload!
  end

  def test_javascript_compression
    packed = @compressor.compress_js(Dir['test/fixtures/src/test*.js'])
    assert packed == File.read('test/fixtures/jammed/test-closure.js')
  end

  def test_jst_compilation
    packed = @compressor.compile_jst(Dir['test/fixtures/src/test*.jst'])
    assert packed == File.read('test/fixtures/jammed/test.jst')
  end

end
