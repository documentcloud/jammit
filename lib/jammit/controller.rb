module Jammit

  # The JammitController is added to your Rails application when the Gem is
  # loaded. It takes responsibility for /assets, and dynamically packages any
  # missing or uncached asset packages.
  class Controller < ActionController::Base

    VALID_FORMATS   = [:css, :js, :jst]

    SUFFIX_STRIPPER = /-(datauri|mhtml)\Z/

    after_filter :cache_package

    # Dispatch to the appropriate packaging method for the filetype.
    def package
      parse_request
      case @format
      when :js  then render :js   => Jammit.packager.pack_javascripts(@package)
      when :css then render :text => generate_stylesheets, :content_type => 'text/css'
      when :jst then render :js   => Jammit.packager.pack_templates(@package)
      end
    rescue Jammit::PackageNotFound
      package_not_found
    end


    private

    # We can't just use the built-in cache_page because we need to ensure that
    # the timestamp that ends up in the MHTML is also on the cached file.
    def cache_package
      cache_page(response.body, request.path)
      if @mtime
        cache_path = page_cache_directory + URI.unescape(request.path.chomp('/'))
        File.utime(@mtime, @mtime, cache_path)
      end
    end

    # Generate the complete MHTML url to be written into the cached stylesheet.
    def asset_url
      return nil unless perform_caching && @variant == :mhtml
      @mtime = Time.now
      host = request.port == 80 ? request.host : request.host_with_port
      "#{request.protocol}#{host}#{Jammit.asset_url(@package, @format, @variant, @mtime)}"
    end

    # If we're generating MHTML/CSS, we need to fix up the absolute URLs with
    # the correct request URL.
    def generate_stylesheets
      css = Jammit.packager.pack_stylesheets(@package, @variant, asset_url)
    end

    # We extract the package name, format (css, js, jst), and
    # variant (datauri, mhtml) from the incoming URL.
    def parse_request
      pack    = params[:package]
      @format = params[:format].to_sym
      raise PackageNotFound unless VALID_FORMATS.include?(@format)
      if Jammit.embed_images
        suffix_match = pack.match(SUFFIX_STRIPPER)
        @variant = Jammit.embed_images && suffix_match && suffix_match[1].to_sym
        pack.sub!(SUFFIX_STRIPPER, '')
      end
      @package = pack.to_sym
    end

    # Render the 404 page, if one exists, for any packages that don't.
    def package_not_found
      not_found_file = "#{RAILS_ROOT}/public/404.html"
      return render(:file => not_found_file, :status => 404) if File.exists?(not_found_file)
      render :text => "<h1>404: \"#{@package}\" asset package not found.</h1>", :status => 404
    end

  end

end

::JammitController = Jammit::Controller

if RAILS_ENV == 'development'
  class ApplicationController < ActionController::Base
    before_filter { Jammit.reload! }
  end
end
