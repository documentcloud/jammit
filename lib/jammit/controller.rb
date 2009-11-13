module Jammit

  class Controller < ActionController::Base

    FORMAT_STRIPPER  = /\.(js|css|jst)\Z/
    SUFFIX_STRIPPER  = /-(datauri|mhtml)\Z/

    caches_page :package

    # Dispatch to the appropriate packaging method for the filetype.
    def package
      parse_request
      case @format
      when :js  then render :js   => Jammit.packager.pack_javascripts(@package)
      when :css then render :text => generate_stylesheets, :content_type => 'text/css'
      when :jst then render :js   => Jammit.packager.pack_templates(@package)
      else           unsupported_media_type
      end
    end


    private

    def generate_stylesheets
      css = Jammit.packager.pack_stylesheets(@package, @variant)
      css.gsub('REQUEST_URL', request_url)
    end

    def request_url
      host = request.port == 80 ? request.host : request.host_with_port
      "#{request.protocol}#{host}#{request.request_uri}"
    end

    def parse_request
      pack = params[:args].last
      @format = pack.match(FORMAT_STRIPPER)[1].to_sym
      pack.sub!(FORMAT_STRIPPER, '')
      if Jammit.embed_images
        suffix_match = pack.match(SUFFIX_STRIPPER)
        @variant = Jammit.embed_images && suffix_match && suffix_match[1].to_sym
        pack.sub!(SUFFIX_STRIPPER, '')
      end
      @package = pack.to_sym
    end

    def unsupported_media_type
      render :text => "Unsupported Media Type: \"#{params[:format]}\"", :status => 415
    end

  end

end

::JammitController = Jammit::Controller

if RAILS_ENV == 'development'
  class ApplicationController < ActionController::Base
    before_filter { Jammit.reload! }
  end
end
