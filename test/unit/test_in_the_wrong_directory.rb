require 'test_helper'

class WrongDirectoryTest < Test::Unit::TestCase

  def setup
    @original_dir ||= File.expand_path(Dir.pwd)
    Dir.chdir('/')
  end

  def teardown
    Dir.chdir(@original_dir)
  end

  def test_fetching_lists_of_individual_urls
    urls = Jammit.packager.individual_urls(:test, :css)
    assert urls == ['/fixtures/src/test1.css', '/fixtures/src/test2.css']
    urls = Jammit.packager.individual_urls(:test, :js)
    assert urls == ['/fixtures/src/test1.js', '/fixtures/src/test2.js']
  end

  def test_packaging_stylesheets
    css = Jammit.packager.pack_stylesheets(:test)
    assert css == File.read("#{ASSET_ROOT}/fixtures/jammed/test.css")
    css = Jammit.packager.pack_stylesheets(:test, :datauri)
    assert css == File.read("#{ASSET_ROOT}/fixtures/jammed/test-datauri.css")
    css = Jammit.packager.pack_stylesheets(:test, :mhtml, 'http://www.example.com')
    assert css == File.read("#{ASSET_ROOT}/fixtures/jammed/test-mhtml.css")
  end

  def test_packaging_javascripts
    js = Jammit.packager.pack_javascripts(:test)
    assert js == File.read("#{ASSET_ROOT}/fixtures/jammed/test.js")
  end

  def test_packaging_templates
    jst = Jammit.packager.pack_templates(:test)
    assert jst == File.read("#{ASSET_ROOT}/fixtures/jammed/test.jst")
  end

end
