module Jammit

  module Helper

    def include_stylesheets(*packages)
      tags = packages.map do |pack|
        DEV ? Jammit.packager.stylesheet_urls(pack.to_sym) : versioned_url(pack, 'css')
      end
      stylesheet_link_tag(tags.flatten)
    end

    def include_javascripts(*packages)
      tags = packages.map do |pack|
        DEV ? Jammit.packager.javascript_urls(pack.to_sym) : versioned_url(pack, 'js')
      end
      javascript_include_tag(tags.flatten)
    end

    def include_jst(*packages)
      javascript_include_tag(packages.map {|pack| versioned_url(pack, 'jst') })
    end


    private

    def versioned_url(package, suffix)
      version_part = Jammit.asset_version ? "-v#{Jammit.asset_version}" : ''
      "/assets/#{package}#{version_part}.#{suffix}"
    end

  end

end
