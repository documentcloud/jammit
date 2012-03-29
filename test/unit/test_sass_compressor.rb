require 'test_helper'

class SassCompressorTest < Test::Unit::TestCase
  def test_css_compression
    Jammit.load_configuration('test/config/assets-sass.yml')
    packed = Compressor.new.compress_css(glob('test/fixtures/src/*.css'))
    assert_equal File.read('test/fixtures/jammed/css_test-sass.css'), packed
  end

end