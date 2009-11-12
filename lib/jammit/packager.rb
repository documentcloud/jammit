module Jammit

  class Packager

    def initialize
      @asset_config   = DEV ? Jammit.load_configuration : ASSET_CONFIG
      @root           = @asset_config[:asset_root] || ''
      @css_config     = @asset_config[:stylesheets].symbolize_keys
      @js_config      = @asset_config[:javascripts].symbolize_keys
      @jst_config     = @asset_config[:jst].symbolize_keys
      @compressor     = Compressor.new
      @css, @js, @jst = nil, nil, nil
    end

    def stylesheet_urls(package)
      stylesheet_packages[package][:urls]
    end

    def javascript_urls(package)
      javascript_packages[package][:urls]
    end

    def jst_urls(package)
      jst_packages[package][:urls]
    end

    def pack_stylesheet(package)
      pack = stylesheet_packages[package]
      raise PackageNotFound, "assets.yml does not contain a '#{package}' stylesheet package" if !pack
      @compressor.compress_css(*pack[:paths])
    end

    def pack_javascript(package)
      pack = javascript_packages[package]
      raise PackageNotFound, "assets.yml does not contain a '#{package}' javascript package" if !pack
      @compressor.compress_js(*pack[:paths])
    end

    def pack_jst(package)
      pack = jst_packages[package]
      raise PackageNotFound, "assets.yml does not contain a '#{package}' jst package" if !pack
      @compressor.compile_jst(*pack[:paths])
    end

    def stylesheet_packages
      @css ||= create_packages(@css_config)
    end

    def javascript_packages
      @js ||= create_packages(@js_config)
    end

    def jst_packages
      @jst ||= create_packages(@jst_config)
    end


    private

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