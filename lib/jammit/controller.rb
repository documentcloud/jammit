module Jammit
  
  class Controller < ActionController::Base
    
    caches_page :jst, :javascripts, :stylesheets
    
    def javascripts
      render :js => Jammit.packager.pack_javascript(params[:package].to_sym)
    end
    
    def stylesheets
      render :text => Jammit.packager.pack_stylesheet(params[:package].to_sym), :content_type => 'text/css'
    end
    
    def jst
      render :js => Jammit.packager.pack_jst(params[:package].to_sym)
    end
    
  end
  
end

::JammitController = Jammit::Controller