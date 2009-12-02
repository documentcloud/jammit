module Jammit

  # The Jammit::Packager resolves the configuration file into lists of real
  # assets that get merged into individual asset packages. Given the compiled
  # contents of an asset package, the Packager knows how to cache that package
  # with the correct timestamps.
  class Packager

    # In Rails, the difference between a path and an asset URL is "public".
    PATH_TO_URL = /\A#{ASSET_ROOT}(\/public)?/

    # Set force to false to allow packages to only be rebuilt when their source
    # files have changed since the last time their package was built.
    attr_accessor :force

    # Creating a new Packager will rebuild the list of assets from the
    # Jammit.configuration. When assets.yml is being changed on the fly,
    # create a new Packager.
    def initialize
      @compressor = Compressor.new
      @force = false
      @config = {
        :css => (Jammit.configuration[:stylesheets] || {}).symbolize_keys,
        :js  => (Jammit.configuration[:javascripts] || {}).symbolize_keys,
        :jst => (Jammit.configuration[:templates]   || {}).symbolize_keys
      }
      @packages = {
        :css => create_packages(@config[:css]),
        :js  => create_packages(@config[:js]),
        :jst => create_packages(@config[:jst])
      }
    end

    # Ask the packager to precache all defined assets, along with their gzip'd
    # versions. In order to prebuild the MHTML stylesheets, we need to know the
    # base_url, because IE only supports MHTML with absolute references.
    # Unless forced, will only rebuild assets whose source files have been
    # changed since their last package build.
    def precache_all(output_dir=nil, base_url=nil)
      output_dir ||= File.join(PUBLIC_ROOT, Jammit.package_path)
      cacheable(:js, output_dir).each  {|p| cache(p, 'js',  pack_javascripts(p), output_dir) }
      cacheable(:jst, output_dir).each {|p| cache(p, 'jst', pack_templates(p),  output_dir) }
      cacheable(:css, output_dir).each do |p|
        cache(p, 'css', pack_stylesheets(p), output_dir)
        if Jammit.embed_images
          cache(p, 'css', pack_stylesheets(p, :datauri), output_dir, :datauri)
          if Jammit.mhtml_enabled && base_url
            mtime = Time.now
            asset_url = "#{base_url}#{Jammit.asset_url(p, :css, :mhtml, mtime)}"
            cache(p, 'css', pack_stylesheets(p, :mhtml, asset_url), output_dir, :mhtml, mtime)
          end
        end
      end
    end

    # Caches a single prebuilt asset package and gzips it at the highest
    # compression level. Ensures that the modification time of both both
    # variants is identical, for web server caching modules, as well as MHTML.
    def cache(package, extension, contents, output_dir, suffix=nil, mtime=Time.now)
      FileUtils.mkdir_p(output_dir) unless File.exists?(output_dir)
      raise OutputNotWritable, "Jammit doesn't have permission to write to \"#{output_dir}\"" unless File.writable?(output_dir)
      filename = File.join(output_dir, Jammit.filename(package, extension, suffix))
      zip_name = "#{filename}.gz"
      File.open(filename, 'wb+') {|f| f.write(contents) }
      Zlib::GzipWriter.open(zip_name, Zlib::BEST_COMPRESSION) {|f| f.write(contents) }
      File.utime(mtime, mtime, filename, zip_name)
    end

    # Get the list of individual assets for a package.
    def individual_urls(package, extension)
      package_for(package, extension)[:urls]
    end

    # Return the compressed contents of a stylesheet package.
    def pack_stylesheets(package, variant=nil, asset_url=nil)
      @compressor.compress_css(package_for(package, :css)[:paths], variant, asset_url)
    end

    # Return the compressed contents of a javascript package.
    def pack_javascripts(package)
      @compressor.compress_js(package_for(package, :js)[:paths])
    end

    # Return the compiled contents of a JST package.
    def pack_templates(package)
      @compressor.compile_jst(package_for(package, :jst)[:paths])
    end


    private

    # Look up a package asset list by name, raising an exception if the
    # package has gone missing.
    def package_for(package, extension)
      pack = @packages[extension] && @packages[extension][package]
      pack || not_found(package, extension)
    end

    # Absolute globs are absolute -- relative globs are relative to ASSET_ROOT.
    def glob_files(glob)
      absolute = Pathname.new(glob).absolute?
      Dir[absolute ? glob : File.join(ASSET_ROOT, glob)].sort
    end

    # Return a list of all of the packages that should be cached. If "force" is
    # true, this is all of them -- otherwise only the packages whose source
    # files have changed since the last package build.
    def cacheable(extension, output_dir)
      names = @packages[extension].keys
      return names if @force
      return names.select do |name|
        pack    = package_for(name, extension)
        cached  = File.join(output_dir, Jammit.filename(name, extension))
        since   = File.exists?(cached) && File.mtime(cached)
        !since || pack[:paths].any? {|src| File.mtime(src) > since }
      end
    end

    # Compiles the list of assets that goes into each package. Runs an ordered
    # list of Dir.globs, taking the merged unique result.
    def create_packages(config)
      packages = {}
      return packages if !config
      config.each do |name, globs|
        globs                  ||= []
        packages[name]         = {}
        paths                  = globs.map {|glob| glob_files(glob) }.flatten.uniq
        packages[name][:paths] = paths
        packages[name][:urls]  = paths.map {|path| path.sub(PATH_TO_URL, '') }
      end
      packages
    end

    # Raise a PackageNotFound exception for missing packages...
    def not_found(package, extension)
      raise PackageNotFound, "assets.yml does not contain a \"#{package}\" #{extension.to_s.upcase} package"
    end

  end

end