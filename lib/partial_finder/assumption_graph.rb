module PartialFinder
  # AssumptionGraph accepts a standard Graph class and augments it with more information about
  # how each render chain terminates, ie what controller method is used and what route points
  # to said controller method.
  #
  # Given the flexiblity of metaprogramming and the many edge cases that exist even in a
  # system with good conventions like the Rails rendering system, it's best to consider the
  # guesses that this class makes exactly that - guesses, and sometimes manual checking may be
  # needed to ensure the correctness of it's output.
  #
  # See Graph and LinkSet for more information on the primitives that this class is based on.
  class AssumptionGraph < Graph
    attr_reader :custom_rails_root

    # Custom rails root needs to be set if the Rails root and current working directory
    # of this class are not the same. This is needed to properly load and read controller
    # code. Usually they will be the same, but during testing or when used outside of the
    # standard rake context, this must be set.
    def initialize(links, custom_rails_root = nil)
      super(links)
      @custom_rails_root = custom_rails_root
      @structure = structure.map{ |link| add_assumptions_to(link) }
    end

    def self.from(path,root)
      new(LinkSet.new(path,root))
    end

    private

    def add_assumptions_to(link)
      if link.parent.is_a? Array
        link.parent.each{ |li| add_assumptions_to(li) }
      else
        link.parent = assumptions_for(link)
      end

      link
    end

    def assumptions_for(link)
      case Formatter.type_of(link.parent)
      when :partial
        new_parent = "This render chain may be unused".colorize(:yellow)
      when :view
        new_parent = new_parent_for_view(link.parent)
      when :controller
        new_parent = new_parent_for_controller(link)
      else
        new_parent = "Unable to identify type of #{path}".colorize(:red)
      end

      [Link.new(link.parent, new_parent)]
    end

    def new_parent_for_controller(link)
      if custom_rails_root.present?
        methods = Formatter.methods_that_render(link.child, link.parent, custom_rails_root)
      else
        methods = Formatter.methods_that_render(link.child, link.parent)
      end

      if methods.any?
        sigs = methods
          .map{ |method| Formatter.controller_signature(link.parent, method) }

        sig_str = sigs
          .join(', ')
          .remove(/,\z/)
        sig_msg = "Rendered by #{sig_str}".colorize(:green)

        routes = sigs.flat_map{ |sig| Router.routes_from(sig) }

        if routes.any?
          routes = routes
            .join(', ')
            .remove(/,\z/)
          route_msg = "Routes to #{routes}".colorize(:green)
        else
          route_msg = "No routes found".colorize(:red)
        end
      else
        sig_msg = "Method lookup failed".colorize(:red)
        route_msg = "Routing not possible since method lookup failed".colorize(:red)
      end

      [Link.new(sig_msg, route_msg)]
    end

    def new_parent_for_view(path)
      # TODO: technically a view can be rendered via calls like
      # render template, but this isn't accounted for
      # TODO: A controller might not actually have the method
      # it is assumed to have. Check this eventually
      # TODO: mailers are not accounted for
      sig = Formatter.controller_signature_from_view(path)
      routes = Router.routes_from(sig)

      if routes.any?
        routes = routes
          .join(', ')
          .remove(/,\z/)
        route_msg = "Routes to #{routes}".colorize(:green)
      else
        route_msg = "Could not find route for #{sig}".colorize(:red)
      end

      [Link.new("Rendered by #{sig}".colorize(:green), route_msg)]
    end
  end
end
