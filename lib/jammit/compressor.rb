module Jammit

  # Uses the YUI Compressor or Closure Compiler to compress JavaScript.
  # Always uses YUI to compress CSS (Which means that Java must be installed.)
  # Also knows how to create a concatenated JST file.
  # If "embed_images" is turned on, creates "mhtml" and "datauri" versions of
  # all stylesheets, with all enabled images inlined into the css.
  class Compressor

    # Mapping from extension to mime-type of all embeddable images.
    IMAGE_MIME_TYPES = {
      '.png'  => 'image/png',
      '.jpg'  => 'image/jpeg',
      '.jpeg' => 'image/jpeg',
      '.gif'  => 'image/gif',
      '.tif'  => 'image/tiff',
      '.tiff' => 'image/tiff'
    }


    IMAGE_DETECTOR  = /url\(['"]?([^\s)]+\.(png|jpg|jpeg|gif|tif|tiff))['"]?\)/
    IMAGE_EMBED     = /[\A\/]embed\//
    IMAGE_REPLACER  = /url\(__EMBED__([^\s)]+)\)/

    # MHTML file constants.
    MHTML_START     = "/*\r\nContent-Type: multipart/related; boundary=\"JAMMIT_MHTML_SEPARATOR\"\r\n\r\n"
    MHTML_SEPARATOR = "--JAMMIT_MHTML_SEPARATOR\r\n"
    MHTML_END       = "*/\r\n"

    # JST file constants.
    JST_START       = "(function(){window.JST = window.JST || {};"
    JST_END         = "})();"

    COMPRESSORS = {
      :yui     => YUI::JavaScriptCompressor,
      :closure => Closure::Compiler
    }

    DEFAULT_OPTIONS = {
      :yui     => {:munge => true},
      :closure => {}
    }

    # Creating a compressor initializes the internal YUI Compressor from
    # the "yui-compressor" gem, or the internal Closure Compiler from the
    # "closure-compiler" gem.
    def initialize
      @css_compressor = YUI::CssCompressor.new
      flavor          = Jammit.javascript_compressor
      @options        = DEFAULT_OPTIONS[flavor].merge(Jammit.compressor_options)
      @js_compressor  = COMPRESSORS[flavor].new(@options)
    end

    # Concatenate together a list of JavaScript paths, and pass them through the
    # YUI Compressor (with munging enabled).
    def compress_js(paths)
      js = concatenate(paths)
      @options[:disabled] ? js : @js_compressor.compress(js)
    end

    # Concatenate and compress a list of CSS stylesheets. When compressing a
    # :datauri or :mhtml variant, post-processes the result to embed
    # referenced images.
    def compress_css(paths, variant=nil, asset_url=nil)
      css = concatenate_and_tag_images(paths, variant)
      css = @css_compressor.compress(css) unless @options[:disabled]
      case variant
      when nil      then return css
      when :datauri then return with_data_uris(css)
      when :mhtml   then return with_mhtml(css, asset_url)
      else raise PackageNotFound, "\"#{variant}\" is not a valid stylesheet variant"
      end
    end

    # Compiles a single JST file by writing out a javascript that adds
    # template properties to a top-level "window.JST" object. Adds a
    # JST-compilation function to the top of the package, unless you've
    # specified your own preferred function, or turned it off.
    # JST templates are named with the basename of their file.
    def compile_jst(paths)
      compiled = paths.map do |path|
        template_name = File.basename(path, File.extname(path))
        contents      = File.read(path).gsub(/\n/, '').gsub("'", '\\\\\'')
        "window.JST.#{template_name} = #{Jammit.template_function}('#{contents}');"
      end
      compiler = Jammit.include_jst_script ? File.read(DEFAULT_JST_SCRIPT) : '';
      [JST_START, compiler, compiled, JST_END].flatten.join("\n")
    end


    private

    # In order to support embedded images from relative paths, we need to
    # expand the paths before contatenating the CSS together and losing the
    # location of the original stylesheet path. Validate the images while we're
    # at it.
    def concatenate_and_tag_images(paths, variant=nil)
      stylesheets = [paths].flatten.map do |css_path|
        File.read(css_path).gsub(IMAGE_DETECTOR) do |url|
          ipath, cpath = Pathname.new($1), Pathname.new(File.expand_path(css_path))
          is_url = URI.parse($1).absolute?
          is_url ? url : "url(#{rewrite_image_path(ipath, cpath, !!variant)})"
        end
      end
      stylesheets.join("\n")
    end

    # Re-write all enabled image URLs in a stylesheet with their corresponding
    # Data-URI Base-64 encoded image contents.
    def with_data_uris(css)
      css.gsub(IMAGE_REPLACER) do |url|
        "url(\"data:#{mime_type($1)};base64,#{encoded_contents($1)}\")"
      end
    end

    # Re-write all enabled image URLs in a stylesheet with the MHTML equivalent.
    # The newlines ("\r\n") in the following method are critical. Without them
    # your MHTML will look identical, but won't work.
    def with_mhtml(css, asset_url)
      paths, index = {}, 0
      css = css.gsub(IMAGE_REPLACER) do |url|
        i = paths[$1] ||= "#{index += 1}-#{File.basename($1)}"
        "url(mhtml:#{asset_url}!#{i})"
      end
      mhtml = paths.map do |path, identifier|
        mime, contents = mime_type(path), encoded_contents(path)
        [MHTML_SEPARATOR, "Content-Location: #{identifier}\r\n", "Content-Type: #{mime}\r\n", "Content-Transfer-Encoding: base64\r\n\r\n", contents, "\r\n"]
      end
      [MHTML_START, mhtml, MHTML_END, css].flatten.join('')
    end

    # Return a rewritten image URL for a new stylesheet -- the image should
    # be tagged for embedding if embeddable, and referenced at the correct level
    # if relative.
    def rewrite_image_path(image_path, css_path, embed=false)
      public_path = absolute_path(image_path, css_path)
      return "__EMBED__#{public_path}" if embed && embeddable?(public_path)
      image_path.absolute? ? image_path.to_s : relative_path(public_path)
    end

    # Get the site-absolute public path for an image file path that may or may
    # not be relative, given the path of the stylesheet that contains it.
    def absolute_path(image_pathname, css_pathname)
      (image_pathname.absolute? ?
        Pathname.new(File.join(PUBLIC_ROOT, image_pathname)) :
        css_pathname.dirname + image_pathname).cleanpath
    end

    # CSS images that are referenced by relative paths, and are *not* being
    # embedded, must be rewritten relative to the newly-merged stylesheet path.
    def relative_path(absolute_path)
      File.join('../', absolute_path.sub(PUBLIC_ROOT, ''))
    end

    # An image is valid for embedding if it exists, is less than 32K, and is
    # stored somewhere inside of a folder named "embed".
    # IE does not support Data-URIs larger than 32K, and you probably shouldn't
    # be embedding images that large in any case.
    def embeddable?(image_path)
      image_path.to_s.match(IMAGE_EMBED) && image_path.exist? && image_path.size < 32.kilobytes
    end

    # Return the Base64-encoded contents of an image on a single line.
    def encoded_contents(image_path)
      Base64.encode64(File.read(image_path)).gsub(/\n/, '')
    end

    # Grab the mime-type of an image, by filename.
    def mime_type(image_path)
      IMAGE_MIME_TYPES[File.extname(image_path)]
    end

    # Concatenate together a list of asset files.
    def concatenate(paths)
      [paths].flatten.map {|p| File.read(p) }.join("\n")
    end

  end

end
