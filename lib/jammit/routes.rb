module Jammit

  # Rails 2.x routing module.
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

# Rails 3.x routes.
if defined?(Jammit::Railtie)
  Jammit::Railtie.routes do
    match "/#{Jammit.package_path}/:package.:extension",
      :to => 'jammit#package', :as => 'jammit'
  end
end