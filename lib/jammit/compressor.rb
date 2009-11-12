module Jammit

  # Uses the YUI Compressor to compress JavaScript and CSS. Also knows how to
  # create a concatenated JST file.
  class Compressor

    JST_NAMER = /\/(\w+)\.jst\Z/

    def initialize
      @yui_js  = YUI::JavaScriptCompressor.new(:munge => true)
      @yui_css = YUI::CssCompressor.new
    end

    # Delegates to the YUI compressor.
    def compress_js(*paths)
      @yui_js.compress(concatenate(paths))
    end

    # Delegates to the YUI compressor.
    def compress_css(*paths)
      @yui_css.compress(concatenate(paths))
    end

    # Compiles a single JST file by writing out a javascript that adds
    # template properties to a "window.JST" object. Adds a JST-compilation
    # function, unless you've specified your own preferred function.
    def compile_jst(*paths)
      compiled = paths.map { |path|
        template_name = path.match(JST_NAMER)[1]
        contents      = File.read(path).gsub(/\n/, '').gsub("'", '\\\\\'')
        "window.JST.#{template_name} = #{Jammit.template_function}('#{contents}');"
      }.join("\n")
      (Jammit.template_function == JST_COMPILER ? JST_SCRIPT : '') + compiled
    end


    private

    # Concatenate together a list of asset files -- unfortunately we have to
    # read them into memory to use the YUI gem. At least it only happens once,
    # period.
    def concatenate(paths)
      [paths].flatten.map {|p| File.read(p) }.join("\n")
    end

  end

end
