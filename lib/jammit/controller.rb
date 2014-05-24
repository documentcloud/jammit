require 'rack'

module Jammit

  # defined somewhere else
  # but for temporarily development
  def self.public_root
    '/public'
  end

  def self.template_extension
    'js'
  end


  class Request < Rack::Request

    VALID_FORMATS   = [:css, :js]

    SUFFIX_STRIPPER = /-(datauri|mhtml)\Z/

    NOT_FOUND_PATH  = "#{Jammit.public_root}/404.html"

    def asset_path?
      path_info =~ /^\/assets/
    end

    def asset_from_path
      path_info =~ /^\/assets\/([\w\.]+)/
      $1
    end

    def extension_from_path
      path_info =~ /\.([\w\.]+)$/
      $1
    end

    def path_info
      @env['PATH_INFO']
    end

    # Extracts the package name, extension (:css, :js), and variant (:datauri,
    # :mhtml) from the incoming URL.
    def parse_request
      pack       = asset_from_path
      @extension = extension_from_path.to_sym
      puts @extension.inspect
      raise PackageNotFound unless (VALID_FORMATS + [Jammit.template_extension.to_sym]).include?(@extension)
      if Jammit.embed_assets
        suffix_match = pack.match(SUFFIX_STRIPPER)
        @variant = Jammit.embed_assets && suffix_match && suffix_match[1].to_sym
        pack.sub!(SUFFIX_STRIPPER, '')
      end
      @package = pack.to_sym
    end

    # Tells the Jammit::Packager to cache and gzip an asset package. We can't
    # just use the built-in "cache_page" because we need to ensure that
    # the timestamp that ends up in the MHTML is also on the cached file.
    def cache_package
      dir = File.join(page_cache_directory, Jammit.package_path)
      Jammit.packager.cache(@package, @extension, @contents, dir, @variant, @mtime)
    end

    # The "package" action receives all requests for asset packages that haven't
    # yet been cached. The package will be built, cached, and gzipped.
    def package
      parse_request
      template_ext = Jammit.template_extension.to_sym
      case @extension
      when :js
        puts @package.inspect
         (@contents = Jammit.packager.pack_javascripts(@package))
      when template_ext
         # (@contents = Jammit.packager.pack_templates(@package))
         'foo_case2.jst'
      when :css
          [generate_stylesheets, :content_type => 'text/css']
      end
      # cache_package if perform_caching && (@extension != template_ext)
    rescue Jammit::PackageNotFound
      package_not_found
    end

    def for_jammit?
      get? &&               # GET on js resource in :hosted_at (fast, check first)
      asset_path?
    end
  end

  class Response < Rack::Response
 
    # Rack response tuple accessors.
    attr_accessor :status, :headers, :body

    def initialize(env, asset)
      @env = env
      @body = asset
      @status = 200 # OK
      @headers = Rack::Utils::HeaderHash.new
    
      headers["Content-Length"] = self.class.content_length(body).to_s
    end

    class << self

      # Calculate appropriate content_length
      def content_length(body)
        if body.respond_to?(:bytesize)
          body.bytesize
        else
          body.size
        end
      end

    end
    
    # Generate the complete, timestamped, MHTML url -- if we're rendering a
    # dynamic MHTML package, we'll need to put one URL in the response, and a
    # different one into the cached package.
    def prefix_url(path)
      host = request.port == 80 ? request.host : request.host_with_port
      "#{request.protocol}#{host}#{path}"
    end

    # If we're generating MHTML/CSS, return a stylesheet with the absolute
    # request URL to the client, and cache a version with the timestamped cache
    # URL swapped in.
    def generate_stylesheets
      return @contents = Jammit.packager.pack_stylesheets(@package, @variant) unless @variant == :mhtml
      @mtime      = Time.now
      request_url = prefix_url(request.fullpath)
      cached_url  = prefix_url(Jammit.asset_url(@package, @extension, @variant, @mtime))
      css         = Jammit.packager.pack_stylesheets(@package, @variant, request_url)
      @contents   = css.gsub(request_url, cached_url) if perform_caching
      css
    end


    # Render the 404 page, if one exists, for any packages that don't.
    def package_not_found
      return render(:file => NOT_FOUND_PATH, :status => 404) if File.exists?(NOT_FOUND_PATH)
      render :text => "<h1>404: \"#{@package}\" asset package not found.</h1>", :status => 404
    end

    def to_rack
      [status, headers.to_hash, [body]]
    end
  end

  # The JammitController is added to your Rails application when the Gem is
  # loaded. It takes responsibility for /assets, and dynamically packages any
  # missing or uncached asset packages.
  class Controller

    def initialize(app, options={})
      @app = app
      # yield self if block_given?
      # validate_options
    end

    def call(env)
      dup.call!(env)
    end
    
    def call!(env)
      env['jammit'] = self
      
      if (@request = Request.new(env.dup.freeze)).for_jammit?
        Response.new(env.dup.freeze, @request.package).to_rack
      else
        status, headers, body = @app.call(env)

        processor = HeaderProcessor.new(body)
        processor.process!(env)

       [ status, headers, processor.new_body ]
      end
    end
  end

end
