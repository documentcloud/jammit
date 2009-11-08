require 'rake/testtask'

desc 'Run all tests'
task :test do
  $LOAD_PATH.unshift(File.expand_path('test'))
  require 'redgreen' if Gem.available?('redgreen')
  require 'test/unit'  
  Dir['test/**/test_*.rb'].each {|test| require test }
end

namespace :gem do
  
  desc 'Build and install the jammit gem'
  task :install do
    sh "gem build jammit.gemspec"
    sh "sudo gem install #{Dir['*.gem'].join(' ')} --local --no-ri --no-rdoc"
  end
  
  desc 'Uninstall the jammit gem'
  task :uninstall do
    sh "sudo gem uninstall -x jammit"
  end
  
end

task :default => :test
