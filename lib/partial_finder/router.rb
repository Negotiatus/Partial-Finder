module PartialFinder
  module Router
    def self.routes
      @@routes ||= `rake routes`
    end

    # Input string must be in the format controller_name#method,
    # ie "users_controller#create".
    # Returns a list of strings that correspond to the routes that
    # point to the given controller.
    def self.routes_from(controller_sig)
      entries = routes
        .scan(/^.+  \/(.+)\(\.:format\) +(#{controller_sig})/)
        .first

      if entries.present?
        entries
          .reject{ |a| a == controller_sig }
          .map{ |a| "/#{a}" }
      else
        []
      end
    end
  end
end
