# Wraps YUI css compressor to use the same API as the rest of
# Jammit's compressors.
class Jammit::YUICssCompressor
  def initialize(options = {})
    @compressor = YUI::CssCompressor.new(options)
  end

  def compress(css)
    @compressor.compress(css)
  end
end