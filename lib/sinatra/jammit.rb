require 'jammit' unless defined?(Jammit)
require 'jammit/route_methods'

module Sinatra

  # The Jammit::Sinatra module is automatically registered
  # in "classic" Sinatra applications upon requiring
  # 'sinatra/jammit'. In modular applications, you must
  # explicitly register it in your Sinatra app with
  #
  #    register Sinatra::Jammit
  #
  # Once registered, it takes responsibility for /assets,
  # and dynamically packages any missing asset packages.
  # Jammit's gzipping feature is automatically enabled if
  # Sinatra::Cache is registered prior to Sinatra::Jammit.
  # Jammit's view helpers are automatically included if
  # Sinatra::StaticAssets is registered prior to Sinatra::Jammit.
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
        settings.cache_enabled
      rescue
        false
      end

      def page_cache_directory
        settings.cache_output_dir
      rescue
        File.join(settings.public, 'cache')
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

        # Sinatra doesn't have the stylesheet_link_tag, etc
        # methods that Jammit uses to provide view helpers.
        # However, Sinatra::StaticAssets does provide these
        # helpers, so we'll only include the Jammit::Helper
        # if the underlying methods are present.
        helpers ::Jammit::Helper if prototype.respond_to?(:stylesheet_link_tag) &&
                                    prototype.respond_to?(:javascript_include_tag)

        # This action receives all requests for asset packages.
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