module PartialFinder
  # Printer class can accept and stringify any class that implements #structure such that
  # #structure returns an array of Links.
  class Printer
    attr_reader :structure, :string

    TAB = "  ".freeze

    # Can be any class that has a #structure method
    def initialize(graph)
      @structure = graph.structure
      @string = ""
      structure.map{ |link| stringify_link(link) }
    end

    private

    def stringify_link(link, depth=0)
      if link.parent.is_a? Array
        @string << indent(depth) + link.child + "\n"
        link.parent.each{ |plink| stringify_link(plink, depth+1) }
      else
        @string << stringify_simple_link(link, depth)
      end
    end

    # Simple link meaning the link parent is not an array
    def stringify_simple_link(link, depth)
      indent(depth) + link.child + "\n" + indent(depth+1) + link.parent + "\n"
    end

    # Returns a string of spaces to represent an indent
    def indent(depth)
      spaces = ""
      depth.times{ spaces << TAB }
      spaces
    end
  end
end
