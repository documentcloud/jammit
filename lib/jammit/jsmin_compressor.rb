# Wraps JSMin compressor to use the same API as the rest of
# Jammit's compressors.
class Jammit::JsminCompressor
  def initialize(options = {})
  end

  def compress(js)
    JSMin.minify(js)
  end
end
