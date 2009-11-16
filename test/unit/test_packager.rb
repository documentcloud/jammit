require 'test_helper'

class PackagerTest < Test::Unit::TestCase

  def test_fetching_lists_of_individual_urls
    urls = Jammit.packager.individual_urls(:test, :css)
    assert urls == ['fixtures/src/test1.css', 'fixtures/src/test2.css']
    urls = Jammit.packager.individual_urls(:test, :js)
    assert urls == ['fixtures/src/test1.js', 'fixtures/src/test2.js']
  end

  def test_packaging_a_css_package
    css = Jammit.packager.pack_stylesheets(:test)
    assert css == File.read('fixtures/jammed/test.css')
    css = Jammit.packager.pack_stylesheets(:test, :datauri)
    assert css == File.read('fixtures/jammed/test-datauri.css')
    css = Jammit.packager.pack_stylesheets(:test, :mhtml, 'http://www.example.com')
    assert css == File.read('fixtures/jammed/test-mhtml.css')
  end

end
