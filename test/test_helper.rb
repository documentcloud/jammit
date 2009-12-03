require 'logger'
RAILS_ROOT = File.expand_path('test') unless defined? RAILS_ROOT

# Mock out missing pieces.
module ActionController
  class Base
    def self.perform_caching
      true
    end
    def self.after_filter(*args)
    end
  end
end

module ActionView
  class Base
  end
end

require 'lib/jammit'

module Rails
  @logger = Logger.new('/dev/null')
  @env = ActiveSupport::StringInquirer.new("test")
  class << self
    attr_reader :logger, :env
  end
end

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
