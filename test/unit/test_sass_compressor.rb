require 'test_helper'

class SassCompressorTest < MiniTest::Test
  def test_css_compression
    Jammit.load_configuration('test/config/assets-sass.yml')

    packed = Compressor.new.compress_css(glob('test/fixtures/src/*.css'))

    assert_equal File.read('test/fixtures/jammed/css_test-sass.css'), packed
  end
  
  def test_scss_to_css
    Jammit.load_configuration('test/config/assets-sass.yml')
    
    packed = Compressor.new.compress_css(glob('test/fixtures/src/*.scss'))
    assert_equal File.read('test/fixtures/jammed/css_test-scss.css').strip, packed
  end

end