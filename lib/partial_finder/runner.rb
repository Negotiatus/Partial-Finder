module PartialFinder
  class Runner
    attr_reader :partial, :graph

    def initialize(partial)
      puts "\n\nStarting the partial finder for #{partial}\n\n"
      @partial = partial
      @graph = Graph.new(partial, root)
    end

    def print_to_console
      puts @graph.links
      puts Printer.new(@graph).to_s
    end

    def root
      # Root defaults to /app directory since greping across
      # the entire repo takes quite a bit of time
      if defined?(Rails)
        "Rails".constantize.root.to_s + "/app"
      else
        "."
      end
    end
  end
end
