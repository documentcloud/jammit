require 'test_helper'
require 'zlib'

class CommandLineTest < MiniTest::Test

  def teardown
    begin
      FileUtils.rm_r('test/precache')
    rescue Errno::ENOENT
    end
  end

  def test_version_and_help_can_run
    assert system('bin/jammit -v') && system('bin/jammit -h')
  end

  def test_jammit_precaching
    system('bin/jammit -c test/config/assets.yml -o test/precache -u http://www.example.com')
    assert PRECACHED_FILES == glob('test/precache/*')
    assert Zlib::GzipReader.open('test/precache/css_test-datauri.css.gz') {|f| f.read } == File.read('test/fixtures/jammed/css_test-datauri.css')
    assert Zlib::GzipReader.open('test/precache/jst_test.js.gz') {|f| f.read } == File.read('test/fixtures/jammed/jst_test.js')
    assert Zlib::GzipReader.open('test/precache/js_test_with_templates.js.gz') {|f| f.read } == File.read('test/fixtures/jammed/js_test_with_templates.js')
  end

  def test_lazy_precaching
    system('bin/jammit -c test/config/assets.yml -o test/precache -u http://www.example.com')
    assert PRECACHED_FILES == glob('test/precache/*')
    mtime = File.mtime(PRECACHED_FILES.first)
    system('bin/jammit -c test/config/assets.yml -o test/precache -u http://www.example.com')
    assert File.mtime(PRECACHED_FILES.first) == mtime
    system('bin/jammit -c test/config/assets.yml -o test/precache -u http://www.example.com --force')
    assert File.mtime(PRECACHED_FILES.first) > mtime
  end

end
