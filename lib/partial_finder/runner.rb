module PartialFinder
  class Runner
    attr_reader :partial, :root

    def initialize(partial, search_root = nil)
      @root = search_root || default_search_root
      @partial = partial
    end

    def print
      puts "\n\nStarting the partial finder for #{partial} in #{@root}\n\n".colorize(:green)

      Printer.new(
        AssumptionGraph.from(@partial, @root)
      ).string
    end

    def debug
      puts "\n\nStarting the partial finder in debug mode for #{partial} in #{@root}\n\n".colorize(:green)

      links = LinkSet.new(@partial, @root, debug_mode: true)
      graph = Graph.new(links)
      ag = AssumptionGraph.new(graph)

      puts "=== Set of links ===".colorize(:blue)
      puts ag.core_graph.links.map{ |li| li.to_s }.join("\n")
      puts ""
      puts "=== Chains without Assumptions ===".colorize(:blue)
      puts Printer.new(ag.core_graph).string
      puts ""
      puts "=== Full Render Chains ===".colorize(:blue)
      puts Printer.new(ag).string
    end

    def default_search_root
      PartialFinder.default_root + "/app"
    end

    def self.help
<<-MSG.colorize(:blue)
Partial Finder is a tool that helps link a given partial with the controllers and routes that render it. It works by making assumptions about Rail's rendering conventions and greping through the application code and routes.

Conditional rendering logic is not considered. If a view, partial, or controller appears in the output list, this is only a statement that said file MAY render the partial under certain conditions.

While it should handle all common use cases, it doesn't account for every possible edge case and manual greping may still be needed.

Task: Find
Usage: rake partial_finder:find\\['path/to/_partial.html.erb'\\]
Outputs all render chains and tries to match each partial with any controllers and routes that eventually render it.

Task: Debug
Usage: rake partial_finder:debug\\['path/to/_partial.html.erb'\\]
Contains the same output as Find but with additional intermediate steps that can be used to help validate the final results.
MSG
    end
  end
end
