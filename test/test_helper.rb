RAILS_ENV = 'test' unless defined? RAILS_ENV
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

class Test::Unit::TestCase
  include Jammit
end