class Jammit::Uglifier < ::Uglifier
  alias :compress :compile_with_map
end
