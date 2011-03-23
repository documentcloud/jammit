Encoding.default_external = 'ascii' if defined? Encoding

require 'logger'

ASSET_ROOT = File.expand_path(File.dirname(__FILE__))

devnull = RUBY_PLATFORM =~ /mswin|mingw|bccwin|wince|emx/ ? 'nul' : '/dev/null'
RAILS_DEFAULT_LOGGER = Logger.new(devnull)
RAILS_ENV = "test"
RAILS_ROOT = File.expand_path(File.dirname(__FILE__))
ENV["RAILS_ASSET_ID"] = "101"

require './lib/jammit'
Jammit.load_configuration(Jammit::DEFAULT_CONFIG_PATH)

def glob(g)
  Dir.glob(g).sort
end

class Test::Unit::TestCase

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
    test/precache/jst_test_diff_ext.js
    test/precache/jst_test_diff_ext.js.gz
    test/precache/jst_test_diff_ext_and_nested.js
    test/precache/jst_test_diff_ext_and_nested.js.gz
    test/precache/jst_test_nested.js
    test/precache/jst_test_nested.js.gz
    test/precache/jst_test_with_template_base_path_and_multiple_paths.js
    test/precache/jst_test_with_template_base_path_and_multiple_paths.js.gz
    test/precache/jst_test_with_template_base_path_and_single_path.js
    test/precache/jst_test_with_template_base_path_and_single_path.js.gz
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
