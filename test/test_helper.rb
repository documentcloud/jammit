require 'logger'

ASSET_ROOT = File.expand_path('test')
devnull = RUBY_PLATFORM =~ /mswin32/ ? 'nul' : '/dev/null'
RAILS_DEFAULT_LOGGER = Logger.new(devnull)
RAILS_ENV = "test"
RAILS_ROOT = File.expand_path('test')

require 'action_view'
require 'lib/jammit'
gem 'rails'
require 'initializer'
Jammit.load_configuration(Jammit::DEFAULT_CONFIG_PATH)

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

  PRECACHED_SOURCES = %w(
    test/precache/test-datauri.css
    test/precache/test-mhtml.css
    test/precache/test.css
    test/precache/test.js
    test/precache/test.jst
  )

  include Jammit

end
