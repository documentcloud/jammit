module Jammit

  # The Jammit::Packager resolves the list of real assets that get merged into
  # a single asset package.
  class Packager

    # In Rails, the difference between a path and an asset URL is "public".
    PATH_TO_URL = /\A\/?public/

    # Creating a new Packager will rebuild the list of assets from the
    # Jammit.configuration. Useful for changing assets.yml on the fly.
    def initialize
      @compressor = Compressor.new
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
    def precache_all(output_dir=nil, base_url=nil)
      output_dir ||= "public/#{Jammit.package_path}"
      FileUtils.mkdir_p(output_dir) unless File.exists?(output_dir)
      @config[:js].keys.each  {|p| precache(p, 'js',  pack_javascripts(p), output_dir) }
      @config[:jst].keys.each {|p| precache(p, 'jst', pack_templates(p),  output_dir) }
      @config[:css].keys.each do |p|
        precache(p, 'css', pack_stylesheets(p), output_dir)
        if Jammit.embed_images
          precache(p, 'css', pack_stylesheets(p, :datauri), output_dir, :datauri)
          if Jammit.mhtml_enabled && base_url
            mtime = Time.now
            asset_url = "#{base_url}#{Jammit.asset_url(p, :css, :mhtml, mtime)}"
            precache(p, 'css', pack_stylesheets(p, :mhtml, asset_url), output_dir, :mhtml, mtime)
          end
        end
      end
    end

    # Prebuild a single asset package.
    def precache(package, extension, contents, output_dir, suffix=nil, mtime=Time.now)
      filename = File.join(output_dir, Jammit.filename(package, extension, suffix))
      zip_name = "#{filename}.gz"
      File.open(filename, 'wb+') {|f| f.write(contents) }
      Zlib::GzipWriter.open(zip_name, Zlib::BEST_COMPRESSION) {|f| f.write(contents) }
      File.utime(mtime, mtime, filename, zip_name)
    end

    # Get the original list of individual assets for a package.
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

    # Access a package asset list, raises an exception if the package is MIA.
    def package_for(package, extension)
      pack = @packages[extension] && @packages[extension][package]
      pack || not_found(package, extension)
    end

    # Compiles the list of assets that goes into a package. Runs an ordered
    # list of Dir.globs, taking the unique, concatenated result.
    def create_packages(config)
      packages = {}
      return packages if !config
      config.each do |name, globs|
        globs                  ||= []
        packages[name]         = {}
        paths                  = globs.map {|glob| Dir[glob] }.flatten.uniq
        packages[name][:paths] = paths
        packages[name][:urls]  = paths.map {|path| path.sub(PATH_TO_URL, '') }
      end
      packages
    end

    # Raise a 404 for missing packages...
    def not_found(package, extension)
      raise PackageNotFound, "assets.yml does not contain a \"#{package}\" #{extension.to_s.upcase} package"
    end

  end

end