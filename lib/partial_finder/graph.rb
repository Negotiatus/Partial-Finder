module PartialFinder
  # The Graph object assembles individual chain links into a structure that better
  # resembles the multiple render paths of a partial.
  #
  # Specifically, using hash syntax, the structure looks something like:
  # { original_partial => [{ parent1 => [...] }, { parent2 => [...] }, "terminating_view_file"] }
  # In this example, the partial is directly rendered by "terminating_view_file" and
  # has a deeper rendering chain up to 2 other parents somewhere.
  #
  # Chains will terminate in a string instead of an array (ie, the parent will be a string).
  # These strings presumably will be either a controller or a view, but if the partial is unused, it could
  # also terminate in itself or another partial.
  class Graph
    attr_reader :links, :structure

    def initialize(links)
      raise NonLinkArgument.new(links) unless links.is_a? LinkSet
      @links = links

      if links.any?
        # The usage of 'root' is a side-effect of how #assemble_links works.
        # If given the initial link instead of a new 'root' link, only the first
        # parent of { partial => [parent1, parent2, ...] } will be traversed.
        @structure = assemble_links(Link.new('root', links.first.child)).parent
      else
        @structure = []
      end
    end

    def self.from(path, root)
      new(LinkSet.new(path,root))
    end

    def to_s
      @to_s ||= Printer.new(self).string
    end

    private

    # This is also where controller methods, routing, and looping messages are
    # determined.
    def assemble_links(origin_link)
      found = []

      links.each do |link|
        # If the given arg link is rendered by the link being examined,
        # it's part of the render chain.
        # Ie, if origin_link = { partialC => partialB }, then link
        # { partialB => partialA } is a found link.
        found << link.deep_dup if link.child == origin_link.parent
      end

      # If no links were found, return the new { link => parent_set }
      # that was just built. Otherwise, recurse through the remaining parent
      # links to continue building the render chain.
      if found.any?
        origin_link.parent = found.map{ |link| assemble_links(link) }
      end

      origin_link
    end
  end
end
