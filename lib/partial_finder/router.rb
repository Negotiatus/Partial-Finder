module PartialFinder
  module Router
    def self.routes
      @@routes ||= `rake routes`
    end

    # Input string must be in the format controller_name#method,
    # ie "users_controller#create".
    # Returns a list of strings that correspond to the routes that
    # point to the given controller.
    def self.routes_from(controller_str)
      foo=routes
        .scan(/^.+  \/(.+)\(\.:format\) +(#{controller_str})/)
        .first
        .reject{ |a| a == controller_str }
    end
  end
end
