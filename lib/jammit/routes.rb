module Jammit
  
  module Routes
    
    def self.draw(map)
      map.with_options :controller => 'jammit' do |jammit|
        jammit.connect '/assets/:package.js',  :action => 'javascripts'
        jammit.connect '/assets/:package.css', :action => 'stylesheets'
        jammit.connect '/assets/:package.jst', :action => 'jst'
      end
    end
    
  end
  
end