require 'test_helper'
require 'zlib'

class PackagerTest < Test::Unit::TestCase

  def test_fetching_lists_of_individual_urls
    urls = Jammit.packager.individual_urls(:test, :css)
    assert urls == ['/fixtures/src/test1.css', '/fixtures/src/test2.css', '/fixtures/src/test_fonts.css']
    urls = Jammit.packager.individual_urls(:test, :js)
    assert urls == ['/fixtures/src/test1.js', '/fixtures/src/test2.js']
    urls = Jammit.packager.individual_urls(:test2, :js)
    assert urls == ['/fixtures/src/test1.js', '/fixtures/src/test2.js', '/assets/test2.jst']
  end

  def test_packaging_stylesheets
    css = Jammit.packager.pack_stylesheets(:test)
    assert css == File.read('test/fixtures/jammed/test.css')
    css = Jammit.packager.pack_stylesheets(:test, :datauri)
    assert css == File.read('test/fixtures/jammed/test-datauri.css')
    css = Jammit.packager.pack_stylesheets(:test, :mhtml, 'http://www.example.com')
    assert css == File.read('test/fixtures/jammed/test-mhtml.css')
  end

  def test_packaging_javascripts
    js = Jammit.packager.pack_javascripts(:test)
    assert js == File.read('test/fixtures/jammed/test.js')
  end

  def test_packaging_templates
    jst = Jammit.packager.pack_templates(:test)
    assert jst == File.read('test/fixtures/jammed/test.jst')
    Jammit.set_template_namespace('custom_namespace')
    jst = Jammit.packager.pack_templates(:test)
    Jammit.set_template_namespace('window.JST')
    assert jst == File.read('test/fixtures/jammed/test2.jst')
    jst = Jammit.packager.pack_templates(:test2)
    assert jst == File.read('test/fixtures/jammed/test.jst')
  end

  def test_package_caching
    css = Jammit.packager.pack_stylesheets(:test, :mhtml, 'http://www.example.com')
    mtime = Time.now
    Jammit.packager.cache(:test, :css, css, 'test/public', :mhtml, mtime)
    canonical = File.read('test/fixtures/jammed/test-mhtml.css')
    assert File.read('test/public/test-mhtml.css') == canonical
    assert Zlib::GzipReader.open('test/public/test-mhtml.css.gz') {|f| f.read } == canonical
    FileUtils.rm(['test/public/test-mhtml.css', 'test/public/test-mhtml.css.gz'])
  end

  def test_precache_all
    Jammit.packager.precache_all('test/precache', 'http://www.example.com')
    assert PRECACHED_FILES == Dir['test/precache/*']
    assert Zlib::GzipReader.open('test/precache/test-datauri.css.gz') {|f| f.read } == File.read('test/fixtures/jammed/test-datauri.css')
    assert Zlib::GzipReader.open('test/precache/test.jst.gz') {|f| f.read } == File.read('test/fixtures/jammed/test.jst')
    FileUtils.rm_r('test/precache')
  end

  def test_exceptions_for_unwritable_directories
    return unless File.exists?('text/fixtures/unwritable')
    assert_raises(OutputNotWritable) do
      Jammit.packager.precache_all('test/fixtures/unwritable')
    end
  end

end
