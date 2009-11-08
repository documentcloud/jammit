module Jammit
  
  class Compressor
    
    JST_NAMER = /\/(\w+)\.jst\Z/
    
    def initialize
      @yui_js  = YUI::JavaScriptCompressor.new(:munge => true)
      @yui_css = YUI::CssCompressor.new
    end
    
    def compress_js(*paths)
      @yui_js.compress(concatenate(paths))
    end
    
    def compress_css(*paths)
      @yui_css.compress(concatenate(paths))
    end
    
    def compile_jst(*paths)
      compiled = paths.map { |path|
        template_name = path.match(JST_NAMER)[1]
        contents      = File.read(path).gsub(/\n/, '').gsub("'", '\\\\\'')
        "window.JST.#{template_name} = JST.compile('#{contents}');" 
      }.join("\n")
      JST_SCRIPT + "\n" + compiled
    end
    
    
    private
    
    def concatenate(paths)
      [paths].flatten.map {|p| File.read(p) }.join("\n")
    end
    
  end
  
end