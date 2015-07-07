# Wraps sass' css compressor to use the same API as the rest of
# Jammit's compressors.
class Jammit::SassCompressor
  # Creates a new sass compressor. Jammit::SassCompressor doesn't use
  # any options, the +options+ parameter is there for API
  # compatibility.
  def initialize(options = {})
  end

  # Compresses +css+ using sass' CSS parser, and returns the
  # compressed css.
  def compress(css)
    ::Sass::Engine.new(css, :syntax => :scss, :style => :compressed).render.strip
  end
end
