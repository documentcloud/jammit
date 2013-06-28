if defined?(Rails::Application)
  major = Rails.version.split(".").first.to_i

  # Rails3 routes
  Rails.application.routes.draw do
    match "/#{Jammit.package_path}/:package.:extension",
      :to => 'jammit#package', :as => :jammit, :constraints => {
        # A hack to allow extension to include "."
        :extension => /.+/
      }
  end if major == 3

  # Rails4 routes
  Rails.application.routes.draw do
    get "/#{Jammit.package_path}/:package.:extension",
      :to => 'jammit#package', :as => :jammit, :constraints => {
        # A hack to allow extension to include "."
        :extension => /.+/
      }
  end if major == 4
end
