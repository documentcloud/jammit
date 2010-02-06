require 'test_helper'
require 'zlib'

class CommandLineTest < Test::Unit::TestCase

  def test_version_and_help_can_run
    assert system('bin/jammit -v') && system('bin/jammit -h')
  end

  def test_jammit_precaching
    system('bin/jammit -c test/config/assets.yml -o test/precache -u http://www.example.com')
    assert PRECACHED_FILES == glob('test/precache/*')
    assert Zlib::GzipReader.open('test/precache/test-datauri.css.gz') {|f| f.read } == File.read('test/fixtures/jammed/test-datauri.css')
    assert Zlib::GzipReader.open('test/precache/test.jst.gz') {|f| f.read } == File.read('test/fixtures/jammed/test.jst')
    FileUtils.rm_r('test/precache')
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
