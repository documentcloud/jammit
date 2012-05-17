# Wraps CSSMin compressor to use the same API as the rest of
# Jammit's compressors.
class Jammit::CssminCompressor
  def initialize(options = {})
  end

  def compress(css)
    CSSMin.minify(css)
  end
end
