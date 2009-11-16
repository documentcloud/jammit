require 'test_helper'
require 'zlib'

class PackagerTest < Test::Unit::TestCase

  def test_fetching_lists_of_individual_urls
    urls = Jammit.packager.individual_urls(:test, :css)
    assert urls == ['fixtures/src/test1.css', 'fixtures/src/test2.css']
    urls = Jammit.packager.individual_urls(:test, :js)
    assert urls == ['fixtures/src/test1.js', 'fixtures/src/test2.js']
  end

  def test_packaging_stylesheets
    css = Jammit.packager.pack_stylesheets(:test)
    assert css == File.read('fixtures/jammed/test.css')
    css = Jammit.packager.pack_stylesheets(:test, :datauri)
    assert css == File.read('fixtures/jammed/test-datauri.css')
    css = Jammit.packager.pack_stylesheets(:test, :mhtml, 'http://www.example.com')
    assert css == File.read('fixtures/jammed/test-mhtml.css')
  end

  def test_packaging_javascripts
    js = Jammit.packager.pack_javascripts(:test)
    assert js == File.read('fixtures/jammed/test.js')
  end

  def test_packaging_templates
    jst = Jammit.packager.pack_templates(:test)
    assert jst == File.read('fixtures/jammed/test.jst')
  end

  def test_package_caching
    css = Jammit.packager.pack_stylesheets(:test, :mhtml, 'http://www.example.com')
    mtime = Time.now
    Jammit.packager.cache(:test, :css, css, 'public', :mhtml, mtime)
    canonical = File.read('fixtures/jammed/test-mhtml.css')
    assert File.read('public/test-mhtml.css') == canonical
    assert Zlib::GzipReader.open('public/test-mhtml.css.gz') {|f| f.read } == canonical
    FileUtils.rm(['public/test-mhtml.css', 'public/test-mhtml.css.gz'])
  end

end





# Caches a single prebuilt asset package and gzips it at the highest
# compression level. Ensures that the modification time of both both
# variants is identical, for web server caching modules, as well as MHTML.
def cache(package, extension, contents, output_dir, suffix=nil, mtime=Time.now)
  FileUtils.mkdir_p(output_dir) unless File.exists?(output_dir)
  filename = File.join(output_dir, Jammit.filename(package, extension, suffix))
  zip_name = "#{filename}.gz"
  File.open(filename, 'wb+') {|f| f.write(contents) }
  Zlib::GzipWriter.open(zip_name, Zlib::BEST_COMPRESSION) {|f| f.write(contents) }
  File.utime(mtime, mtime, filename, zip_name)
end