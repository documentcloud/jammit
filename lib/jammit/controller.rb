module Jammit

  class Controller < ActionController::Base

    VERSION_STRIPPER = /-v\d+\Z/

    caches_page :jst, :javascripts, :stylesheets

    # Dispatch to the appropriate packaging method for the filetype.
    def package
      case params[:format]
      when 'js'  then Jammit.packager.pack_javascript(package)
      when 'css' then Jammit.packager.pack_stylesheet(package), :content_type => 'text/css'
      when 'jst' then Jammit.packager.pack_jst(package)
      else       return unsupported_media_type
      end
    end


    private

    def package
      params[:package].sub(VERSION_STRIPPER, '').to_sym
    end

    def unsupported_media_type
      render :text => "Unsupported Media Type: \"#{params[:format]}\"", :status => 415
    end

  end

end

::JammitController = Jammit::Controller