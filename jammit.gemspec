lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'jammit/version'

Gem::Specification.new do |s|
  s.name      = 'jammit'
  s.version   = Jammit::VERSION
  s.date      = '2011-11-30'

  s.homepage    = "http://documentcloud.github.com/jammit/"
  s.summary     = "Industrial Strength Asset Packaging for Rails"
  s.description = <<-EOS
    Jammit is an industrial strength asset packaging library for Rails,
    providing both the CSS and JavaScript concatenation and compression that
    you'd expect, as well as YUI Compressor and Closure Compiler compatibility,
    ahead-of-time gzipping, built-in JavaScript template support, and optional
    Data-URI / MHTML image embedding.
  EOS

  s.authors           = ['Jeremy Ashkenas']
  s.email             = 'jeremy@documentcloud.org'
  s.rubyforge_project = 'jammit'

  s.require_paths     = ['lib']
  s.executables       = ['jammit']

  s.extra_rdoc_files  = ['README']
  s.rdoc_options      << '--title'    << 'Jammit' <<
                         '--exclude'  << 'test' <<
                         '--main'     << 'README' <<
                         '--all'

  s.add_dependency 'cssmin', ['>= 1.0.2']
  s.add_dependency 'jsmin',  ['>= 1.0.1']

  s.files = Dir['lib/**/*', 'bin/*', 'rails/*', 'jammit.gemspec', 'LICENSE', 'README']
end
