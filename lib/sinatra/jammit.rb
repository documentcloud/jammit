require 'jammit'
require 'jammit/route_methods'

module Sinatra

  # The Jammit::Sinatra class is only included when
  # the Sinatra top-level constant is defined. Note that
  # it isn't automatically loaded though, and must be
  # explicitly included in your Sinatra app with
  #    use Jammit::Middleware
  # Once installed, it takes responsibility for /assets, 
  # and dynamically packages any missing asset packages.
  module Jammit

    # Unlike Rails, Sinatra doesn't have a built-in
    # solution for caching. However, Sinatra::Cache
    # is the canonical solution for caching, so
    # let's optimize for that. This ensures that we
    # don't lose Jammit's gzip feature if the app is
    # actually caching.
    module Caching
    private

      def perform_caching
        @app.settings.cache_enabled
      rescue
        false
      end

      def page_cache_directory
        @app.settings.cache_output_dir
      rescue
        File.join(@app.settings.public, 'cache')
      end

    end

    def self.registered(app)
      app.instance_eval do
        include ::Jammit::RouteMethods
        include ::Sinatra::Jammit::Caching
        
        # Development-only reloading
        if development?
          before do
            ::Jammit.reload!
          end
        end

        # This action receives all requests for asset packages. Note that
        # unlike Jammit::Controller, this action makes no attempt to cache.
        get "/#{::Jammit.package_path}/:package.:extension" do
          begin
            parse_request
            case @extension
            when :js
              content_type :js
              @contents = ::Jammit.packager.pack_javascripts(@package)
            when ::Jammit.template_extension.to_sym
              content_type :js
              @contents = ::Jammit.packager.pack_templates(@package)
            when :css
              content_type :css
              generate_stylesheets
            end
            cache_package if perform_caching

            @contents
          rescue ::Jammit::PackageNotFound
            raise ::Sinatra::NotFound
          end
        end

      end
    end
    
  end
  
  register Jammit
end