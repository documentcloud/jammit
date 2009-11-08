ENV['RACK_ENV'] = 'test'

class Test::Unit::TestCase
  include Jammit
end