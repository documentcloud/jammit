module Jammit

  # Helper methods for writing out the environment-appropriate asset tags.
  module Helper

    NO_IE_START = "<!--[if !IE]><!-->"
    NO_IE_END   = "<!--<![endif]-->"
    IE_START    = "<!--[if IE]>"
    IE_END      = "<![endif]-->"

    # If embed_images is turned on, writes out links to the Data-URI and MHTML
    # versions of the stylesheet package, otherwise the package is regular
    # compressed CSS, and in development the stylesheet URLs are passed verbatim.
    def include_stylesheets(*packages)
      return individual_stylesheets(packages) unless Jammit.package_assets
      return embedded_image_stylesheets(packages) if Jammit.embed_images
      return packaged_stylesheets(packages)
    end

    # Writes out the URL to the bundled and compressed javascript package,
    # except in development, where it references the individual links.
    def include_javascripts(*packages)
      tags = packages.map do |pack|
        Jammit.package_assets ? Jammit.asset_url(pack, :js) : Jammit.packager.individual_urls(pack.to_sym, :js)
      end
      javascript_include_tag(tags.flatten)
    end

    # Writes out the URL to the concatenated and compiled JST file -- we always
    # have to pre-process it, even in development.
    def include_jst(*packages)
      javascript_include_tag(packages.map {|pack| Jammit.asset_url(pack, :jst) })
    end


    private

    # HTML tags, in order, for all of the individual stylesheets.
    def individual_stylesheets(packages)
      stylesheet_link_tag(packages.map {|p| Jammit.packager.individual_urls(p.to_sym, :css) }.flatten)
    end

    # HTML tags for the stylesheet packages.
    def packaged_stylesheets(packages)
      stylesheet_link_tag(packages.map {|p| Jammit.asset_url(p, :css) })
    end

    # HTML tags for the 'datauri', and 'mhtml' versions of the packaged
    # stylesheets, using conditional comments to load the correct variant.
    def embedded_image_stylesheets(packages)
      css_tags = stylesheet_link_tag(packages.map {|p| Jammit.asset_url(p, :css, :datauri) })
      ie_tags = if Jammit.mhtml_enabled
        stylesheet_link_tag(packages.map {|p| Jammit.asset_url(p, :css, :mhtml) })
      else
        packaged_stylesheets(packages)
      end
      [NO_IE_START, css_tags, NO_IE_END, IE_START, ie_tags, IE_END].join("\n")
    end

  end

end

# Include the Jammit asset helpers in all views, a-la ApplicationHelper.
::ActionView::Base.send(:include, Jammit::Helper)
