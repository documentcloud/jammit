module Jammit

  # The Jammit::Packager resolves the list of real assets that get merged into
  # a single asset package.
  class Packager

    # The output directory can be overriden as an argument to 'jammit'.
    DEFAULT_OUTPUT_DIRECTORY = 'public/assets'

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
    # versions. We can't prebuild the 'mhtml' stylesheets, because they need
    # to reference their own absolute URL.
    def precache_all(output_dir=nil)
      output_dir ||= DEFAULT_OUTPUT_DIRECTORY
      FileUtils.mkdir_p(output_dir) unless File.exists?(output_dir)
      @config[:js].keys.each  {|p| precache(p, 'js',  pack_javascripts(p), output_dir) }
      @config[:jst].keys.each {|p| precache(p, 'jst', pack_templates(p),  output_dir) }
      @config[:css].keys.each {|p| precache(p, 'css', pack_stylesheets(p), output_dir) }
      @config[:css].keys.each {|p| precache(p, 'css', pack_stylesheets(p, :datauri), output_dir, 'datauri') } if Jammit.embed_images
    end

    # Prebuild a single asset package.
    def precache(package, extension, contents, output_dir, suffix=nil)
      filename = File.join(output_dir, Jammit.filename(package, extension, suffix))
      zip_name = "#{filename}.gz"
      File.open(filename, 'w+') {|f| f.write(contents) }
      Zlib::GzipWriter.open(zip_name, Zlib::BEST_COMPRESSION) {|f| f.write(contents) }
      FileUtils.touch([filename, zip_name])
    end

    # Get the original list of individual assets for a package.
    def individual_urls(package, extension)
      @packages[extension][package][:urls]
    end

    # Return the compressed contents of a stylesheet package.
    def pack_stylesheets(package, variant=nil)
      pack = @packages[:css][package]
      raise PackageNotFound, "assets.yml does not contain a '#{package}' stylesheet package" if !pack
      @compressor.compress_css(pack[:paths], variant)
    end

    # Return the compressed contents of a javascript package.
    def pack_javascripts(package)
      pack = @packages[:js][package]
      raise PackageNotFound, "assets.yml does not contain a '#{package}' javascript package" if !pack
      @compressor.compress_js(pack[:paths])
    end

    # Return the compiled contents of a JST package.
    def pack_templates(package)
      pack = @packages[:jst][package]
      raise PackageNotFound, "assets.yml does not contain a '#{package}' jst package" if !pack
      @compressor.compile_jst(pack[:paths])
    end


    private

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

  end

end