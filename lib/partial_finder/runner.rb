module PartialFinder
  class Runner
    attr_reader :partial, :graph

    def initialize(partial)
      @partial = partial
      @graph = Graph.new(partial, root)
    end

    def print_to_console
      puts Printer.new(@graph).to_s
    end

    def root
      defined?(:Rails) ? "Rails".constantize.root : "."
    end
  end
end
