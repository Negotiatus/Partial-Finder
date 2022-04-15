require "partial_finder/version"
require "partial_finder/formatter"
require "partial_finder/router"
require "partial_finder/runner"
require "partial_finder/printer"
require "partial_finder/link"
require "partial_finder/link_set"
require "partial_finder/graph"
require "partial_finder/assumption_graph"
require "partial_finder/railtie" if defined?(Rails)
require "colorize"
require "active_support/core_ext/object"
require "active_support/core_ext/string"

module PartialFinder
  class NonPartialArgument < StandardError
    def initialize(path)
      super "You may only use this class with partials, but gave '#{path}'"
    end
  end

  class NonLinkArgument < StandardError
    def initialize(arg)
      super "You may only use this class with a LinkSet, but gave '#{arg}'"
    end
  end

  class NonGraphArgument < StandardError
    def initialize(arg)
      super "You may only use this class with a Graph, but gave '#{arg}'"
    end
  end

  def self.default_root
    if defined?(Rails)
      "Rails".constantize.root.to_s
    else
      "."
    end
  end
end
