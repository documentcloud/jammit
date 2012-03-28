# Wraps YUI JS compressor to use the same API as the rest of
# Jammit's compressors.
class Jammit::YUIJavaScriptCompressor
  def initialize(options = {})
    @compressor = YUI::JavaScriptCompressor.new(options)
  end

  def compress(js)
    @compressor.compress(js)
  end
end