module PartialFinder
  module Formatter
    # Takes a file path and turns it into a partial reference. Example:
    # app/views/orders/_order_sidepanel.html.erb
    # becomes
    # orders/order_sidepanel
    # which is the format used when rendering a partial in a controller or view.
    def self.path_to_ref(path)
      ref = path.deep_dup
      ref.remove!('app/views/').remove!(/\.html\.erb\z/)
      ref = ref.split('/')
      ref[-1] = ref.last.remove(/\A_/)
      ref.join('/')
    end

    def self.is_partial?(path)
      !!path.split('/').last.match(/\A_.+\.erb/)
    end

    def self.is_view?(path)
      !!path.split('/').last.match(/[^\A]_.+\.erb/)
    end

    #def self.is_view_or_partial?(path)
    #  is_view?(path) || is_partial?(path)
    #end

    def self.controller_signature_from_view(path)
      cname = path
      cname.remove!('app/views/').remove!('.html.erb')
      cname = cname.split('/')
      method = cname.pop
      "#{cname.join('/')}##{method}"
    end

    def self.controller_signature(path, method)
      cname = path
      cname.remove!('app/controllers/').remove!('_controller.rb')
      "#{cname}##{method}"
    end

    # Searches through a controller
    def self.method_that_renders(partial_path, controller_path)
      fragments = File.open(controller_path).split /def (.+?)$/
      ref = to_ref(partial_path)
      matches = []

      fragments.each.with_index do |fr,i|
        matches << fragments[i-1] if fr.match ref
      end

      matches
    end
  end
end
