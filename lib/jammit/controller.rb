module Jammit

  class Controller < ActionController::Base

    FORMAT_STRIPPER  = /\.(js|css|jst)\Z/
    SUFFIX_STRIPPER  = /-(datauri|mhtml)\Z/

    caches_page :package

    # Dispatch to the appropriate packaging method for the filetype.
    def package
      jam = Jammit.packager
      parse_request
      case @format
      when :js  then render :js   => jam.pack_javascripts(@package)
      when :css then render :text => jam.pack_stylesheets(@package, @variant), :content_type => 'text/css'
      when :jst then render :js   => jam.pack_templates(@package)
      else           unsupported_media_type
      end
    end


    private

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
