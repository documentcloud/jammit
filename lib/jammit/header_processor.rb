module Jammit

  class HeaderProcessor

    attr_reader :content_length, :new_body

    HEAD_TAG_REGEX = /<\/head>|<\/head[^(er)][^<]*>/

    def initialize(body)
      @body = body
    end

    # Add the tags for script and stylesheets to the response
    def process!(env)
      @env = env

      @new_body = @body.map(&:to_s)
      @livereload_added = false

      @new_body.each_with_index do |line, pos|
        if line =~ HEAD_TAG_REGEX
          @pos = pos
          break
        end
      end
      @new_body.insert(@pos, dependencies)
    end

    def dependencies
      ['<link rel="stylesheet" href="/assets/app.css" type="text/css">',
      '<script src="/assets/app.js"></script>'].join
    end


  end

end
