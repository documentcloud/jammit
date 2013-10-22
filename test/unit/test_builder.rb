require 'test_helper'

class BuilderTest < Test::Unit::TestCase

  def setup
    Jammit.load_configuration('test/config/assets-build.yml')
    @packager = Jammit.packager
    @builder = Builder.new
  end

  def teardown
    FileUtils.rm_rf 'test/fixtures/build/'
  end

  def test_javascript_build
    build_file = 'test/fixtures/build/test3/test3.js'
    assert File.exists?(build_file), "Expected #{build_file} to be generated"
  end

end
