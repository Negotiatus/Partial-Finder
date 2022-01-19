module PartialFinder
  class Printer
    attr_reader :graph

    TAB = "  ".freeze

    # Can be given a Graph class or the structure itself.
    def initialize(graph)
      @graph = graph.is_a?(Graph) ? graph.structure : graph
      @string = ""
    end

    def to_s(subgraph = @graph, depth=0)
      if subgraph.is_a? Array
        subgraph.each do |links|
          if links.is_a? String
            @string << indent(depth) + links + "\n"
          else
            @string << indent(depth) + links.keys.first + "\n"
          end

          new_depth = depth + 1

          links.each{ |_,v| to_s(v, new_depth) } if links.is_a? Hash
        end
      else
        @string << indent(depth) + subgraph + "\n"
      end
      @string
    end

    private

    # Returns a string of spaces to represent an indent
    def indent(depth)
      spaces = ""
      depth.times{ spaces << TAB }
      spaces
    end
  end
end
