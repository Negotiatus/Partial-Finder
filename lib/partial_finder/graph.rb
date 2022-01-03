module PartialFinder
  class Graph
    attr_reader :links, :path, :root, :structure

    # Path must be a file path to a partial relative to the given root. In the
    # context of a Rails app, root should just be Rails.root but is exposed as
    # a method arg for testing purposes.
    def initialize(path, root)
      raise NonPartialArgument.new(path) unless Formatter.is_partial?(path)

      @path = path
      @links = []
      @root = root

      @processed_links = []

      collect_links(path)

      # The usage of 'root' is a side-effect of how #build_render_chains works. If given
      # the initial link instead of a new 'root' link, only the first parent of
      # { partial => [parent1, parent2, ...] }
      # will be traversed.
      chains = build_render_chains({ 'root' => path })['root']

      # If `chains` resolves to a string, then there are no files that reference
      # the given partial as that string is simply the name of the given partial.
      @structure = chains.is_a?(String) ? [] : chains.compact
    end

    # Returns a list of files that reference the given partial.
    # Non-partials are not searched for as render chains
    # terminate in non-partials (ie, if a view or controller has
    # been found, the render chain can halt).
    def self.files_that_reference(path, root)
      if Formatter.is_partial? path
        # Accounts for use of " and ' in the reference
        # TODO: Make this single line? Character escaping this properly isn't fun
        term = <<~STR
"partial: [\\"']#{Formatter.path_to_ref(path)}[\\"']"
STR

        puts "Running `cd #{root} && ag -l #{term}`"
        # Collects file paths and removes the beginning "./"
        `cd #{root} && grep -rl #{term}`
          .split("\n")
          .map{ |a| a.remove(/\A\.\//) }
      else
        []
      end
    end

    private

    def files_that_reference(path)
      self.class.files_that_reference(path, root)
    end

    # Recursive method that assembles individual chain links from @links into a structure that
    # better resembles the multiple render paths of a partial. Specifically,
    # { partial => [{ parent1 => [...] }, { parent2 => [...] }] }
    #
    # This is also where controller methods, routing, and looping messages are determined.
    def build_render_chains(origin_link)
      # Processed links is used to guard against infinite loops while putting the render
      # chain together. A single link shouldn't be run through this method more than once.
      if @processed_links.include? origin_link
        return "Loops back to #{origin_link.keys.first}".colorize(:yellow)
      end

      @processed_links << origin_link

      child = origin_link.keys.first
      parent = origin_link.values.first
      found = []

      links.each do |link|
        # If the given arg link is rendered by the link being examined,
        # it's part of the render chain.
        # Ie, if origin_link = { partialC => partialB }, then link
        # { partialB => partialA } is a found link.
        found << link.deep_dup if link.keys.first == parent
      end

      # If no links were found, return the new { link => parent_set }
      # that was just built. Otherwise, recurse through the remaining parent
      # links to continue building the render chain.
      if found.any?
        origin_link[child] = found.map{ |link| build_render_chains(link) }
      else
        #origin_link[child] = [origin_link[child]] << assumed_routes(origin_link)
      end

      origin_link
    end

    def links_are_unique?
      to_str = links.map{ |link| "#{link.keys.first}->#{link.values.first}" }
      to_str.uniq.size == to_str.size
    end

    # Recursive method that returns a list of { render_child_path => render_parent_path }
    # file paths. These paths are the core structure used later on to assemble a full
    # graph-like structure to represent render chains.
    #
    # "Parent" and "child" refer to the order that a view is rendered. The contorller/view
    # that eventually renders a partial is always a parent and the given partial is a child.
    # Ie, { file_that_is_rendered => file_that_renders_it }.
    def collect_links(path)
      files_that_reference(path).each do |parent_path|
        links << { path => parent_path }

        is_unique = links_are_unique?

        # Only continue recursion if there's more partials to look through. A view or
        # controller indicates the end of a render chain. If a dup got added this
        # iteration, an infinite loop must be present so halt recursion even if the
        # current path is a partial path.
        collect_links(parent_path) if Formatter.is_partial?(parent_path) && is_unique

        # If a loop exists and a dup was just added, remove the dup, ie the last link
        links.pop unless is_unique
      end
    end
  end
end
