require 'rake/testtask'

desc 'Run all tests'
task :test, [:path] do |task, args|
  ENV['RAILS_ENV'] = 'test'
  $LOAD_PATH.unshift(File.expand_path('test'))

  if args[:path]
    require args[:path]
  else
    Dir['test/*/**/test_*.rb'].each {|test| require "./#{test}" }
  end
end

desc 'Generate YARD Documentation'
task :doc do
  sh "mv README TEMPME"
  sh "rm -rf doc"
  sh "yardoc"
  sh "mv TEMPME README"
end

namespace :gem do

  desc 'Build and install the jammit gem'
  task :install do
    sh "gem build jammit.gemspec"
    sh "gem install #{Dir['*.gem'].join(' ')} --local --no-ri --no-rdoc"
  end

  desc 'Uninstall the jammit gem'
  task :uninstall do
    sh "gem uninstall -x jammit"
  end

end

task :default => :test
