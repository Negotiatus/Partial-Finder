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
          @string << indent(depth) + links.keys.first + "\n"

          new_depth = depth + 1

          links.each{ |_,v| to_s(v, new_depth) }
        end
      else
        @string << indent(depth) + subgraph + "\n"
      end
      @string
    end

    # TODO
    def assumed_routes(end_link)
      child = end_link.keys.first

      if Formatter.is_view?(path)
        sig = Formatter.controller_signature_from_view(path)
        messages << "Assumed to be rendered by #{sig}"
        route_list = Router.routes_from(sig).join(', ')
        if routes_list.present?
          messages << "Routed to via #{routes_list}".colorize(:green)
        else
          messages << "Could not find any routes to #{sig}".colorize(:yellow)
        end
      else
        methods = Formatter.methods_that_render(child, path)
        sigs = methods.map{ |m| Formatter.controller_signature(path, m) }
      end

      if sig.present?
      else
        messages << "Method lookup failed, cannot determine route".colorize(:red)
      end

      messages
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
