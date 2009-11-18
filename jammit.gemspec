Gem::Specification.new do |s|
  s.name      = 'jammit'
  s.version   = '0.1.3'         # Keep version in sync with jammit.rb
  s.date      = '2009-11-17'

  s.homepage    = "http://documentcloud.github.com/jammit/"
  s.summary     = "Industrial Strength Asset Packaging for Rails"
  s.description = <<-EOS
    Jammit is an industrial strength asset packaging library for Rails,
    providing both the CSS and JavaScript concatenation and compression
    that you'd expect, as well as ahead-of-time gzipping, built-in JavaScript
    template support, and optional Data-URI / MHTML image embedding.
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

  s.add_dependency 'rails', ['>= 2.0.0']
  s.add_dependency 'yui-compressor', ['>= 0.9.1']

  s.files = %w(
bin/jammit
jammit.gemspec
lib/jammit.rb
lib/jammit/command_line.rb
lib/jammit/compressor.rb
lib/jammit/controller.rb
lib/jammit/helper.rb
lib/jammit/jst.js
lib/jammit/packager.rb
lib/jammit/routes.rb
LICENSE
Rakefile
README
)
end