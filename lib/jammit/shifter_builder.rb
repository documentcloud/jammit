class Jammit::ShifterBuilder

  def do_it(js)
    js.map { |p| build_file_2_src_dir p}.each { |j| shift(j) }
  end

  # Replace the build/ dir name to src/ and remove filename from the path
  def build_file_2_src_dir(glob)
    src_glob = glob.gsub(/build/,"src")
    src_dir = src_glob.gsub(/\/[^\/]*\.js$/, "")
    src_dir
  end

  private

  def shift(glob)
    # Try to shift it
    src_dir = glob
    Jammit.warn("Trying to shift #{src_dir}")
    FileUtils.cd(src_dir) do
      `shifter`
    end
  end
end