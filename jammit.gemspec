Gem::Specification.new do |s|
  s.name      = 'jammit'
  s.version   = '0.6.3'         # Keep version in sync with jammit.rb
  s.date      = '2011-05-26'

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

  s.add_dependency 'yui-compressor',    ['>= 0.9.3']

  s.files = Dir['lib/**/*', 'bin/*', 'rails/*', 'jammit.gemspec', 'LICENSE', 'README']
end
