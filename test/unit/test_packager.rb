require 'test_helper'
require 'zlib'

class PackagerTest < Test::Unit::TestCase

  def teardown
    Jammit.set_template_namespace(nil)
    Jammit.set_template_extension(nil)
    begin
      FileUtils.rm_r('test/precache')
    rescue Errno::ENOENT
    end
  end

  def test_fetching_lists_of_individual_urls
    urls = Jammit.packager.individual_urls(:css_test, :css)
    assert urls == ['/fixtures/src/test1.css', '/fixtures/src/test2.css', '/fixtures/src/test_fonts.css']
    urls = Jammit.packager.individual_urls(:js_test, :js)
    assert urls == ['/fixtures/src/test1.js', '/fixtures/src/test2.js']
    urls = Jammit.packager.individual_urls(:js_test_with_templates, :js)
    assert urls == ['/fixtures/src/test1.js', '/fixtures/src/test2.js', '/assets/js_test_with_templates.jst']
  end

  def test_fetching_lists_of_nested_urls
    urls = Jammit.packager.individual_urls(:css_test_nested, :css)
    assert urls == ['/fixtures/src/test1.css', '/fixtures/src/test2.css', '/fixtures/src/test_fonts.css', '/fixtures/src/nested/nested1.css', '/fixtures/src/nested/nested2.css']
    urls = Jammit.packager.individual_urls(:js_test_nested, :js)
    assert urls == ['/fixtures/src/test1.js', '/fixtures/src/test2.js', '/fixtures/src/nested/nested1.js', '/fixtures/src/nested/nested2.js']
    urls = Jammit.packager.individual_urls(:jst_test_nested, :js)
    assert urls == ['/assets/jst_test_nested.jst']
  end

  def test_packaging_stylesheets
    css = Jammit.packager.pack_stylesheets(:css_test)
    assert css == File.read('test/fixtures/jammed/css_test.css')
    css = Jammit.packager.pack_stylesheets(:css_test, :datauri)
    assert css == File.read('test/fixtures/jammed/css_test-datauri.css')
    css = Jammit.packager.pack_stylesheets(:css_test, :mhtml, 'http://www.example.com')
    assert css == File.open('test/fixtures/jammed/css_test-mhtml.css', 'rb') {|f| f.read }
  end

  def test_packaging_javascripts
    js = Jammit.packager.pack_javascripts(:js_test)
    assert js == File.read('test/fixtures/jammed/js_test.js')
    js = Jammit.packager.pack_javascripts(:js_test_with_templates)
    assert js == File.read('test/fixtures/jammed/js_test_with_templates.js')
  end

  def test_packaging_templates
    jst = Jammit.packager.pack_templates(:jst_test)
    assert jst == File.read('test/fixtures/jammed/jst_test.js')
  end

  def test_packaging_templates_when_mixed_with_javascript
    # If you mix in JS with the JST, it shouldn't change the JST output.
    jst = Jammit.packager.pack_templates(:js_test_with_templates)
    assert jst == File.read('test/fixtures/jammed/jst_test.js')
  end

  def test_packaging_templates_with_custom_namespace
    Jammit.set_template_namespace('custom_namespace')
    jst = Jammit.packager.pack_templates(:jst_test)
    assert jst == File.read('test/fixtures/jammed/jst_test-custom-namespace.js')
  end

  def test_packaging_templates_nested
    jst = Jammit.packager.pack_templates(:jst_test_nested)
    assert jst == File.read('test/fixtures/jammed/jst_test_nested.js')
  end

  def test_package_caching
    css = Jammit.packager.pack_stylesheets(:css_test, :mhtml, 'http://www.example.com')
    mtime = Time.now
    Jammit.packager.cache(:css_test, :css, css, 'test/public', :mhtml, mtime)
    canonical = File.open('test/fixtures/jammed/css_test-mhtml.css', 'rb') {|f| f.read }
    assert File.open('test/public/css_test-mhtml.css', 'rb') {|f| f.read } == canonical
    assert Zlib::GzipReader.open('test/public/css_test-mhtml.css.gz') {|f| f.read } == canonical
    FileUtils.rm(['test/public/css_test-mhtml.css', 'test/public/css_test-mhtml.css.gz'])
  end

  def test_precache_all
    Jammit.load_configuration('test/config/assets.yml').reload!
    Jammit.packager.precache_all('test/precache', 'http://www.example.com')
    assert PRECACHED_FILES == glob('test/precache/*')
    assert Zlib::GzipReader.open('test/precache/css_test-datauri.css.gz') {|f| f.read } == File.read('test/fixtures/jammed/css_test-datauri.css')
  end

  def test_precache_no_gzip
    Jammit.load_configuration('test/config/assets-compression-disabled.yml').reload!
    Jammit.packager.precache_all('test/precache', 'http://www.example.com')
    assert PRECACHED_SOURCES == glob('test/precache/*')
    Jammit.load_configuration('test/config/assets.yml').reload!
  end

  def test_precache_regenerates_css_variants
    Jammit.load_configuration('test/config/assets-compression-disabled.yml').reload!
    Jammit.packager.precache_all('test/precache', 'http://www.example.com')
    assert_equal PRECACHED_SOURCES, glob('test/precache/*')

    File.unlink("test/precache/css_test-mhtml.css")
    File.unlink("test/precache/css_test-datauri.css")

    Jammit.packager.precache_all('test/precache', 'http://www.example.com')
    assert_equal PRECACHED_SOURCES, glob('test/precache/*')
  end

  def test_exceptions_for_unwritable_directories
    return unless File.exists?('text/fixtures/unwritable')
    assert_raises(OutputNotWritable) do
      Jammit.packager.precache_all('test/fixtures/unwritable')
    end
  end

  def test_package_helper
    FileUtils.rm_rf("test/public/assets/*")
    Jammit.package! :config_file => "test/config/assets.yml", :base_url => "http://example.com/"
    assert File.exists?("test/public/assets/js_test.js")
    assert File.exists?("test/public/assets/css_test.css")
    FileUtils.rm_rf("test/public/assets")
  end

  def test_packaging_javascripts_with_package_names
    FileUtils.rm_rf("test/public/assets/*")
    Jammit.package! :config_file => "test/config/assets.yml", :package_names => [:js_test]
    assert File.exists?("test/public/assets/js_test.js")
    assert File.read('test/public/assets/js_test.js') == File.read('test/fixtures/jammed/js_test_package_names.js')
    FileUtils.rm_rf("test/public/assets")
  end

end
