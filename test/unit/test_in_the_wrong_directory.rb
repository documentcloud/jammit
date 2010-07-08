require 'test_helper'

class WrongDirectoryTest < Test::Unit::TestCase

  def setup
    Jammit.load_configuration('test/config/assets.yml').reload!
    @original_dir ||= File.expand_path(Dir.pwd)
    Dir.chdir('/')
  end

  def teardown
    Dir.chdir(@original_dir)
  end

  def test_fetching_lists_of_individual_urls
    urls = Jammit.packager.individual_urls(:css_test, :css)
    assert urls == ['/fixtures/src/test1.css', '/fixtures/src/test2.css', '/fixtures/src/test_fonts.css']
    urls = Jammit.packager.individual_urls(:js_test, :js)
    assert urls == ['/fixtures/src/test1.js', '/fixtures/src/test2.js']
  end

  def test_packaging_stylesheets
    css = Jammit.packager.pack_stylesheets(:css_test)
    assert css == File.read("#{ASSET_ROOT}/fixtures/jammed/css_test.css")
    css = Jammit.packager.pack_stylesheets(:css_test, :datauri)
    assert css == File.read("#{ASSET_ROOT}/fixtures/jammed/css_test-datauri.css")
    css = Jammit.packager.pack_stylesheets(:css_test, :mhtml, 'http://www.example.com')
    assert css == File.open("#{ASSET_ROOT}/fixtures/jammed/css_test-mhtml.css", 'rb') {|f| f.read }
  end

  def test_packaging_javascripts
    js = Jammit.packager.pack_javascripts(:js_test)
    assert js == File.read("#{ASSET_ROOT}/fixtures/jammed/js_test.js")
  end

  def test_packaging_templates
    jst = Jammit.packager.pack_templates(:jst_test)
    assert jst == File.read("#{ASSET_ROOT}/fixtures/jammed/jst_test.js")
  end

end
