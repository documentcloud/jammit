require 'test_helper'

class SassCompressorTest < Test::Unit::TestCase

  def setup
    Jammit.load_configuration('test/config/assets-sass.yml').reload!
    @compressor = Compressor.new
  end

  def teardown
    Jammit.load_configuration('test/config/assets.yml').reload!
  end

  def test_css_compression
    packed = @compressor.compress_css(glob('test/fixtures/src/*.css'))
    assert_equal File.read('test/fixtures/jammed/css_test.css'), packed
  end

end