require 'logger'

ASSET_ROOT = File.expand_path('test')
RAILS_DEFAULT_LOGGER = Logger.new('/dev/null')
RAILS_ENV = "test"

require 'lib/jammit'
gem 'rails'
require 'initializer'

class Test::Unit::TestCase

  PRECACHED_FILES = %w(
    test/precache/test-datauri.css
    test/precache/test-datauri.css.gz
    test/precache/test-mhtml.css
    test/precache/test-mhtml.css.gz
    test/precache/test.css
    test/precache/test.css.gz
    test/precache/test.js
    test/precache/test.js.gz
    test/precache/test.jst
    test/precache/test.jst.gz
  )

  include Jammit

end
