require "partial_finder/version"
require "partial_finder/formatter"
require "partial_finder/router"
require "partial_finder/printer"
require "partial_finder/graph"
require "active_support/all"
require "colorize"

module PartialFinder
  class NonPartialArgument < StandardError
    def initialize(path)
      super "You may only use this class with partials, but gave #{path}"
    end
  end
end
