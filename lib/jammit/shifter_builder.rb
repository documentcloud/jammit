class Jammit::ShifterBuilder

  def do_it(js)
    js.map { |p| build_file_2_src_dir p}.each { |j| shift(j) }
  end

  # Get the dir name to src/
  def build_file_2_src_dir(glob)
    build_root = glob[/(.*)\/build\/(.*)/,1]
    build_root+'/src/' if build_root
  end

  private

  def shift(glob)
    # Try to shift it
    src_dir = glob
    Jammit.warn("Trying to shift #{src_dir}")
    FileUtils.cd(src_dir) do
      Dir.glob('*').select {|f| File.directory? f}.each do |mod|
        FileUtils.cd(mod) do
          `shifter`
        end
      end
    end
  end
end