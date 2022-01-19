require 'forwardable'

module PartialFinder
  # LinkSet is a simple collection of { render_child => render_parent } file paths.
  # Given a partial path and a file root to search, it will recursively search for
  # and collect render links for that partial.
  # This is the base structure that is used to generate and print full render chains.
  class LinkSet
    extend Forwardable
    attr_reader :path, :root, :values

    delegate [:any?, :each, :map, :[], :first] => :@values

    # Accepts a file path to a partial and a file path used as the search root.
    # The search root can be expanded or shrunk as needed, but is allowed to be
    # flexible since the size of the search directory can drastically effect the
    # performance of grep. It is recommended to use rails_root/app.
    def initialize(partial_path, root)
      raise NonPartialArgument.new(partial_path) unless Formatter.is_partial?(partial_path)

      @path = partial_path
      @root = root
      @values = []
      collect_links(path)
    end

    # Returns a list of files that reference the given partial.
    # Non-partials are not searched for as render chains
    # terminate in non-partials (ie, if a view or controller has
    # been found, the render chain can halt).
    def self.files_that_reference(path, root)
      if Formatter.is_partial? path
        # Scans for instances of the partial being explicitly rendered.
        # For example, given the path app/views/orders/_foo.html.erb, the
        # resulting string used by grep would be:
        # "partial: [\"']orders/foo[\"']"
        # This accounts for use of " and ' in the reference.
        #
        # TODO: Make this single line? Character escaping this properly isn't fun
        term = <<~STR.remove("\n")
"partial: [\\"']#{Formatter.path_to_ref(path)}[\\"']"
STR

        `cd #{root} && grep -rl #{term}`
          .split("\n")
          .map{ |a| Formatter.full_view_path(a) }
      else
        []
      end
    end

    private

    def files_that_reference(path)
      self.class.files_that_reference(path, root)
    end

    # Stringify each link and compare strings
    def links_are_unique?
      values.uniq.size == values.size
    end

    # Recursive method that returns a list of
    # { render_child_path => render_parent_path }
    # file paths. These paths are the core structure used later on to assemble a
    # full graph-like structure to represent render chains.
    #
    # "Parent" and "child" refer to the order that a view is rendered. The
    # contorller/view that eventually renders a partial is always a parent and
    # the given partial is a child.
    # Ie, { file_that_is_rendered => file_that_renders_it }.
    def collect_links(path)
      files_that_reference(path).each do |parent_path|
        values << Link.new(path, parent_path)

        # Only continue recursion if there's more partials to look through. A view
        # or controller indicates the end of a render chain.
        collect_links(parent_path) if Formatter.is_partial?(parent_path) #&& links_are_unique?

        #values.pop unless links_are_unique?
      end
    end
  end
end
