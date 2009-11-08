Gem::Specification.new do |s|
  s.name      = 'jammit'
  s.version   = '0.1.0'         # Keep version in sync with jammit.rb
  s.date      = '2009-11-06'

  s.homepage    = "http://wiki.github.com/documentcloud/jammit"
  s.summary     = "Asset Packaging, Javascript Templates, YUI Compressed"
  s.description = <<-EOS
    Lorem Ipsum.
  EOS
  
  s.authors           = ['Jeremy Ashkenas']
  s.email             = 'jeremy@documentcloud.org'
  s.rubyforge_project = 'jammit'
  
  s.require_paths     = ['lib']
  s.executables       = ['jammit']
    
  s.has_rdoc          = true
  s.extra_rdoc_files  = ['README']
  s.rdoc_options      << '--title'    << 'Jammit' <<
                         '--exclude'  << 'test' <<
                         '--main'     << 'README' <<
                         '--all'
  
  s.add_dependency 'rails'
  s.add_dependency 'yui-compressor', ['>= 0.9.1']
  
  s.files = %w(
jammit.gemspec
lib/jammit.rb
lib/jammit/controller.rb
lib/jammit/compressor.rb
lib/jammit/helper.rb
lib/jammit/jst.js
lib/jammit/packager.rb
lib/jammit/routes.rb
LICENSE
Rakefile
README
)
end