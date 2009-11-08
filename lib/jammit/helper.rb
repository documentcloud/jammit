module Jammit
  
  module Helper
   
    def include_stylesheets(*packages)
      tags = packages.map {|p| DEV ? Jammit.packager.stylesheet_urls(p.to_sym) : "/assets/#{p}.css" }
      stylesheet_link_tag(tags.flatten)
    end
    
    def include_javascripts(*packages)
      tags = packages.map {|p| DEV ? Jammit.packager.javascript_urls(p.to_sym) : "/assets/#{p}.js" }
      javascript_include_tag(tags.flatten)
    end
    
    def include_jst(*packages)
      javascript_include_tag(packages.map {|p| "/assets/#{p}.jst" })
    end
    
  end
  
end
