module Jammit

  # Uses the YUI Compressor to compress JavaScript and CSS. (Which means that
  # Java must be installed.) Also knows how to create a concatenated JST file.
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

    # Detect all image URLs that are inside of an "embed" folder.
    IMAGE_DETECTOR  = /url\(['"]?(\/[^\s)]*embed\/[^\s)]+\.(png|jpg|jpeg|gif|tif|tiff))['"]?\)/

    # MHTML file constants.
    MHTML_START     = "/*\r\nContent-Type: multipart/related; boundary=\"JAMMIT_MHTML_SEPARATOR\"\r\n\r\n"
    MHTML_SEPARATOR = "--JAMMIT_MHTML_SEPARATOR\r\n"
    MHTML_END       = "*/\r\n"

    # JST file constants.
    JST_START       = "(function(){window.JST = window.JST || {};"
    JST_END         = "})();"

    # Creating a compressor initializes the internal YUI Compressor from
    # the "yui-compressor" gem.
    def initialize
      @yui_js  = YUI::JavaScriptCompressor.new(:munge => true)
      @yui_css = YUI::CssCompressor.new
    end

    # Concatenate together a list of JavaScript paths, and pass them through the
    # YUI Compressor (with munging enabled).
    def compress_js(paths)
      @yui_js.compress(concatenate(paths))
    end

    # Concatenate and compress a list of CSS stylesheets. When compressing a
    # :datauri or :mhtml variant, post-processes the result to embed
    # referenced images.
    def compress_css(paths, variant=nil, asset_url=nil)
      compressed_css = @yui_css.compress(concatenate(paths))
      case variant
      when nil      then compressed_css
      when :datauri then with_data_uris(compressed_css)
      when :mhtml   then with_mhtml(compressed_css, asset_url)
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

    # Re-write all enabled image URLs in a stylesheet with their corresponding
    # Data-URI Base-64 encoded image contents.
    def with_data_uris(css)
      css.gsub(IMAGE_DETECTOR) do |url|
        image_path = "public#{$1}"
        valid_image(image_path) ? "url(\"data:#{mime_type(image_path)};base64,#{encoded_contents(image_path)}\")" : url
      end
    end

    # Re-write all enabled image URLs in a stylesheet with the MHTML equivalent.
    # The newlines ("\r\n") in the following method are critical. Without them
    # your MHTML will look identical, but won't work.
    def with_mhtml(css, asset_url)
      paths = {}
      css = css.gsub(IMAGE_DETECTOR) do |url|
        image_path = "public#{$1}"
        valid = valid_image(image_path)
        paths[$1] ||= image_path if valid
        valid ? "url(mhtml:#{asset_url}!#{$1})" : url
      end
      mhtml = paths.map do |identifier, path|
        mime, contents = mime_type(path), encoded_contents(path)
        [MHTML_SEPARATOR, "Content-Location: #{identifier}\r\n", "Content-Type: #{mime}\r\n", "Content-Transfer-Encoding: base64\r\n\r\n", contents, "\r\n"]
      end
      [MHTML_START, mhtml, MHTML_END, css].flatten.join('')
    end

    # An image is valid if it exists, and is less than 32K.
    # IE does not support Data-URIs larger than 32K, and you probably shouldn't
    # be embedding images that large in any case.
    def valid_image(image_path)
      File.exists?(image_path) && File.size(image_path) < 32.kilobytes
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
