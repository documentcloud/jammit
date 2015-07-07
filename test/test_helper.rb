Encoding.default_external = 'ascii' if defined? Encoding

require 'pry'
require 'logger'

ASSET_ROOT = File.expand_path(File.dirname(__FILE__))

devnull = RUBY_PLATFORM =~ /mswin|mingw|bccwin|wince|emx/ ? 'nul' : '/dev/null'
ENV['RAILS_ENV'] ||= "test"
ENV["RAILS_ASSET_ID"] = "101"

require './lib/jammit'
Jammit.load_configuration(Jammit::DEFAULT_CONFIG_PATH)

def glob(g)
  Dir.glob(g).sort
end

require 'minitest/autorun'


class MiniTest::Test

  PRECACHED_FILES = %w(
    test/precache/css_test-datauri.css
    test/precache/css_test-datauri.css.gz
    test/precache/css_test-mhtml.css
    test/precache/css_test-mhtml.css.gz
    test/precache/css_test.css
    test/precache/css_test.css.gz
    test/precache/css_test_nested-datauri.css
    test/precache/css_test_nested-datauri.css.gz
    test/precache/css_test_nested-mhtml.css
    test/precache/css_test_nested-mhtml.css.gz
    test/precache/css_test_nested.css
    test/precache/css_test_nested.css.gz
    test/precache/js_test.js
    test/precache/js_test.js.gz
    test/precache/js_test_nested.js
    test/precache/js_test_nested.js.gz
    test/precache/js_test_with_templates.js
    test/precache/js_test_with_templates.js.gz
    test/precache/jst_test.js
    test/precache/jst_test.js.gz
    test/precache/jst_test_nested.js
    test/precache/jst_test_nested.js.gz
  )

  PRECACHED_SOURCES = %w(
    test/precache/css_test-datauri.css
    test/precache/css_test-mhtml.css
    test/precache/css_test.css
    test/precache/js_test.js
    test/precache/jst_test.js
  )

  include Jammit

end
