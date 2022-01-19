require "partial_finder/version"
require "partial_finder/formatter"
require "partial_finder/router"
require "partial_finder/runner"
require "partial_finder/printer"
require "partial_finder/link"
require "partial_finder/link_set"
require "partial_finder/graph"
require "colorize"
require "partial_finder/railtie" if defined?(Rails)

# TODO: smaller scope
require "active_support/all"

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
end
