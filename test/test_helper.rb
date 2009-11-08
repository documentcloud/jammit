RAILS_ENV = 'test' unless defined? RAILS_ENV
RAILS_ROOT = File.expand_path('test') unless defined? RAILS_ROOT

# Mock out missing pieces.
module ActionController
  class Base
    def self.caches_page(*args)
    end
  end
end

module ActionView
  class Base
  end
end

require 'lib/jammit'

class Test::Unit::TestCase
  include Jammit
end