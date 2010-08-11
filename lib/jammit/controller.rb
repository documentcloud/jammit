require 'jammit/route_methods'

module Jammit

  # The JammitController is added to your Rails application when the Gem is
  # loaded. It takes responsibility for /assets, and dynamically packages any
  # missing or uncached asset packages.
  class Controller < ActionController::Base
    include Jammit::RouteMethods

    # The "package" action receives all requests for asset packages that haven't
    # yet been cached. The package will be built, cached, and gzipped.
    def package
      parse_request
      case @extension
      when :js
        render :js => (@contents = Jammit.packager.pack_javascripts(@package))
      when Jammit.template_extension.to_sym
        render :js => (@contents = Jammit.packager.pack_templates(@package))
      when :css
        render :text => generate_stylesheets, :content_type => 'text/css'
      end
      cache_package if perform_caching
    rescue Jammit::PackageNotFound
      package_not_found
    end

  end

end

# Make the Jammit::Controller available to Rails as a top-level controller.
::JammitController = Jammit::Controller

if defined?(Rails) && Rails.env.development?
  ActionController::Base.class_eval do
    append_before_filter { Jammit.reload! }
  end
end
