module Jammit

  class Packager

    DEFAULT_OUTPUT_DIRECTORY = 'public/assets'

    def initialize
      @root           = (Jammit.configuration[:asset_root]  || '')
      @css_config     = (Jammit.configuration[:stylesheets] || {}).symbolize_keys
      @js_config      = (Jammit.configuration[:javascripts] || {}).symbolize_keys
      @jst_config     = (Jammit.configuration[:templates]   || {}).symbolize_keys
      @compressor     = Compressor.new
      @css, @js, @jst = nil, nil, nil
    end

    def precache_all(output_dir=nil)
      output_dir ||= DEFAULT_OUTPUT_DIRECTORY
      versioned_dir = output_dir + (Jammit.asset_version ? "/v#{Jammit.asset_version}" : '')
      FileUtils.mkdir_p(versioned_dir) unless File.exists?(versioned_dir)
      @css_config.keys.each {|p| precache(p, 'css', pack_stylesheets(p), output_dir) }
      @js_config.keys.each  {|p| precache(p, 'js',  pack_javascripts(p), output_dir) }
      @jst_config.keys.each {|p| precache(p, 'jst', pack_templates(p),  output_dir) }
    end

    def precache(package, extension, contents, output_dir)
      filename = File.join(output_dir, Jammit.filename(package, extension))
      File.open(filename, 'w+')         {|f| f.write(contents) }
      File.open("#{filename}.gz", 'w+') {|f| f.write(compress(contents)) }
    end

    def stylesheet_urls(package)
      stylesheet_packages[package][:urls]
    end

    def javascript_urls(package)
      javascript_packages[package][:urls]
    end

    def template_urls(package)
      template_packages[package][:urls]
    end

    def pack_stylesheets(package)
      pack = stylesheet_packages[package]
      raise PackageNotFound, "assets.yml does not contain a '#{package}' stylesheet package" if !pack
      @compressor.compress_css(*pack[:paths])
    end

    def pack_javascripts(package)
      pack = javascript_packages[package]
      raise PackageNotFound, "assets.yml does not contain a '#{package}' javascript package" if !pack
      @compressor.compress_js(*pack[:paths])
    end

    def pack_templates(package)
      pack = template_packages[package]
      raise PackageNotFound, "assets.yml does not contain a '#{package}' jst package" if !pack
      @compressor.compile_jst(*pack[:paths])
    end

    def stylesheet_packages
      @css ||= create_packages(@css_config)
    end

    def javascript_packages
      @js ||= create_packages(@js_config)
    end

    def template_packages
      @jst ||= create_packages(@jst_config)
    end


    private

    def compress(contents)
      deflater = Zlib::Deflate.new(Zlib::BEST_COMPRESSION)
      compressed = deflater.deflate(contents, Zlib::FINISH)
      deflater.close
      compressed
    end

    def create_packages(config)
      packages = {}
      return packages if !config
      config.each do |name, globs|
        packages[name] = {}
        paths = packages[name][:paths] = unique_paths(globs)
        packages[name][:urls]  = paths_to_urls(paths)
      end
      packages
    end

    def unique_paths(globs)
      globs.map {|glob| Dir[glob] }.flatten.uniq
    end

    def paths_to_urls(paths)
      paths.map {|path| path.sub(/\Apublic/, @root) }
    end

  end

end