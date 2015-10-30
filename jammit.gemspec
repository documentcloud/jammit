Gem::Specification.new do |s|
  s.name      = 'jammit'
  s.version   = '0.7.1'         # Keep version in sync with jammit.rb
  s.license   = 'MIT'
  s.date      = '2015-10-28'

  s.homepage    = "http://documentcloud.github.com/jammit/"
  s.summary     = "Industrial-strength asset packaging for Rails."
  s.description = <<-EOS
    Jammit is an industrial-strength asset packaging library for Rails,
    providing both the CSS and JavaScript concatenation and compression that
    you'd expect, as well as YUI Compressor and Closure Compiler compatibility,
    ahead-of-time gzipping, built-in JavaScript template support, and optional
    Data-URI / MHTML image embedding.
  EOS

  s.authors           = ['Jeremy Ashkenas', 'Ted Han', 'Justin Reese']
  s.email             = ['opensource@documentcloud.org']

  s.require_paths     = ['lib']
  s.executables       = ['jammit']

  s.extra_rdoc_files  = ['README.md']
  s.rdoc_options      << '--title'    << 'Jammit' <<
                         '--exclude'  << 'test' <<
                         '--main'     << 'README.md' <<
                         '--all'

  s.add_dependency 'cssmin', ['~> 1.0']
  s.add_dependency 'jsmin',  ['~> 1.0']

  s.files = Dir['lib/**/*', 'bin/*', 'rails/*', 'jammit.gemspec', 'LICENSE', 'README.md']
end
