require 'test_helper'

class ClosureCompressorTest < Test::Unit::TestCase

  def setup
    Jammit.load_configuration('assets-closure.yml').reload!
    @compressor = Compressor.new
  end

  def teardown
    Jammit.load_configuration('assets.yml').reload!
  end

  def test_javascript_compression
    packed = @compressor.compress_js(Dir['fixtures/src/test*.js'])
    assert packed == File.read('fixtures/jammed/test-closure.js')
  end

  def test_jst_compilation
    packed = @compressor.compile_jst(Dir['fixtures/src/test*.jst'])
    assert packed == File.read('fixtures/jammed/test.jst')
  end

end
