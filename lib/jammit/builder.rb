
module Jammit
  # A builder needs
  # - to expose a 'do_it' method to build the given files
  # - to expose a 'build_file_2_src_dir' method to get the src folder form the build file
  class Builder

    JAVASCRIPT_BUILDERS = {
      :shifter    => Jammit.javascript_builders.include?(:shifter)  ? Jammit::ShifterBuilder : nil
    }

    def initialize
      if Jammit.javascript_builders.include?(:shifter)
        Jammit.check_shifter
      end
      js_flavor       = Jammit.javascript_builder || Jammit::DEFAULT_JAVASCRIPT_BUILDER
      @js_builder     = JAVASCRIPT_BUILDERS[js_flavor].new
    end

    # YUI Shifter to build JS modules
    def build_js(paths)
      paths = [paths] unless paths.is_a? Array
      if Jammit.build_assets
        @js_builder.do_it(paths)
      end
    end

    # Check if src file has changed
    def changed?(glob)
      src_dir = @js_builder.build_file_2_src_dir glob
      Jammit.files_changed.any? { |js| js.include? src_dir }
    end

  end

end
