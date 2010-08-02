if defined?(Rails::Application)
  # Rails3 routes
  Rails.application.routes.draw do |map|
    match "/#{Jammit.package_path}/:package.:extension",
      :to => 'jammit#package', :as => :jammit
  end
end
