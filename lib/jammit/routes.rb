module Jammit

  module Routes

    # Jammit uses a single route in order to slow down Rails' routing speed
    # by the absolute minimum. In your config/routes.rb file, call:
    #   Jammit::Routes.draw(map)
    # Passing in the routing "map" object.
    def self.draw(map)
      map.jammit "/#{Jammit.package_path}/:package.:extension",
                 :controller => 'jammit', :action => 'package'
    end

  end

end