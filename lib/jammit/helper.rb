module Jammit

  module Helper

    NO_IE_START = "<!--[if !IE]><!-->"
    NO_IE_END   = "<!--<![endif]-->"
    IE_START    = "<!--[if IE]>"
    IE_END      = "<![endif]-->"

    # If embed_images is turned on, writes out links to the Data-URI and MHTML
    # versions of the stylesheet package, otherwise the package is regular
    # compressed CSS, and in development the stylesheet URLs are passed verbatim.
    def include_stylesheets(*packages)
      return individual_stylesheets(packages) if Jammit.development?
      return embedded_image_stylesheets(packages) if Jammit.embed_images
      return packaged_stylesheets(packages)
    end

    # Writes out the URL to the bundled and compressed javascript package,
    # except in development, where it references the individual links.
    def include_javascripts(*packages)
      tags = packages.map do |pack|
        Jammit.development? ? Jammit.packager.javascript_urls(pack.to_sym) : versioned_url(pack, 'js')
      end
      javascript_include_tag(tags.flatten)
    end

    # Writes out the URL to the concatenated and compiled JST file -- we always
    # have to pre-process it, even in development.
    def include_jst(*packages)
      javascript_include_tag(packages.map {|pack| versioned_url(pack, 'jst') })
    end


    private

    def versioned_url(package, extension, suffix=nil)
      File.join('/assets', Jammit.filename(package, extension, suffix))
    end

    def individual_stylesheets(packages)
      stylesheet_link_tag(packages.map {|p| Jammit.packager.stylesheet_urls(p.to_sym) }.flatten)
    end

    def packaged_stylesheets(packages)
      stylesheet_link_tag(packages.map {|p| versioned_url(p, 'css') })
    end

    def embedded_image_stylesheets(packages)
      [ NO_IE_START,
        stylesheet_link_tag(packages.map {|p| versioned_url(p, 'css', 'datauri') }),
        NO_IE_END,
        IE_START,
        stylesheet_link_tag(packages.map {|p| versioned_url(p, 'css', 'mhtml') }),
        IE_END
      ].join("\n")
    end

  end

  ::ActionView::Base.send(:include, Helper)

end
