$: << File.expand_path(File.dirname(__FILE__) + "/..") ; require 'test_helper'
require 'zlib'

class CommandLineTest < Test::Unit::TestCase
  JAMMIT = "bundle exec bin/jammit"

  def setup
    ENV['RAILS_ROOT'] = 'test'
  end

  def teardown
    begin
      FileUtils.rm_r('test/precache')
    rescue Errno::ENOENT
    end
  end

  def test_version_and_help_can_run
    assert system("#{ JAMMIT } -v > /dev/null")
    assert system("#{ JAMMIT } -h > /dev/null")
  end

  def test_jammit_precaching
    system("#{ JAMMIT } -c test/config/assets.yml -o test/precache -u http://www.example.com")
    assert_equal PRECACHED_FILES, glob('test/precache/*')

    assert_equal zlib_read('test/precache/css_test-datauri.css.gz'),
      File.read('test/fixtures/jammed/css_test-datauri.css')

    assert_equal zlib_read('test/precache/jst_test.js.gz'),
      File.read('test/fixtures/jammed/jst_test.js')

    assert_equal zlib_read('test/precache/js_test_with_templates.js.gz'),
      File.read('test/fixtures/jammed/js_test_with_templates.js')
  end

  def test_lazy_precaching
    system("#{ JAMMIT } -c test/config/assets.yml -o test/precache -u http://www.example.com")
    assert_equal PRECACHED_FILES, glob('test/precache/*')
    mtime = File.mtime(PRECACHED_FILES.first)
    system("#{ JAMMIT } -c test/config/assets.yml -o test/precache -u http://www.example.com")
    assert_equal File.mtime(PRECACHED_FILES.first), mtime
    system("#{ JAMMIT } -c test/config/assets.yml -o test/precache -u http://www.example.com --force")
    assert File.mtime(PRECACHED_FILES.first) > mtime
  end

  def zlib_read(filename)
    Zlib::GzipReader.open(filename) {|f| f.read }
  end

end
