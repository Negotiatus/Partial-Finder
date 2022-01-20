module PartialFinder
  module Formatter
    # Takes a file path and turns it into a partial reference. Example:
    # app/views/orders/_order_sidepanel.html.erb
    # becomes
    # orders/order_sidepanel
    # which is the format used when rendering a partial in a controller or view.
    def self.path_to_ref(path)
      ref = path.deep_dup
      ref.remove!('app/').remove!('views/').remove!(/\.html\.erb\z/)
      ref = ref.split('/')
      ref[-1] = ref.last.remove(/\A_/)
      ref.join('/')
    end

    def self.is_partial?(path)
      return false unless path.present?
      !!path.split('/').last.match(/\A_.+\.erb/)
    end

    def self.is_view?(path)
      return false unless path.present?
      !!path.split('/').last.match(/\A[^_].+\.erb/)
    end

    def self.is_controller?(path)
      return false unless path.present?
      !!path.split('/').last.match(/.+_controller\.rb/)
    end

    # Takes a view path that can be complete or have missing/extra
    # parts and returns it in the format
    # app/views/any_subfolders/view_file.html.erb
    # or
    # app/controllers/any_subfolders/controller_file.html.erb
    #
    # This is needed mainly when the search directly for grep is altered
    # and parts of the path need to be restored and scrubbed of the
    # leading ./ characters.
    def self.fix_path(incomplete_path)
      path = incomplete_path.remove(/\A\.\//)

      if path.match(/\Aviews/) || path.match(/\Acontrollers/)
        "app/#{path}"
      elsif !path.match /\Aapp/
        is_view?(path) ? "app/views/#{path}" : "app/controllers/#{path}"
      else
        path
      end
    end

    # Determines if the given path is a partial, a view, a controller
    # or none of the above
    def self.type_of(path)
      if is_partial?(path)
        :partial
      elsif is_view?(path)
        :view
      elsif is_controller?(path)
        :controller
      else
        :unknown
      end
    end

    # Given a view path, the controller name and method that implicitly
    # renders it are assumed by convention. A controller signature is returned.
    # If the path is not a view, an empty string is returned.
    def self.controller_signature_from_view(path)
      if is_view?(path)
        cname = path.deep_dup
        cname.remove!('app/').remove!('views/').remove!('.html.erb')
        cname = cname.split('/')
        method = cname.pop
        "#{cname.join('/')}##{method}"
      else
        ""
      end
    end

    # Returns a controller signature constructed from a controller's view path
    # and a manually specified method name.
    # If the path is not a controller, an empty string is returned.
    def self.controller_signature(path, method)
      if is_controller?(path)
        cname = path.deep_dup
        cname.remove!('app/').remove!('controllers/').remove!('_controller.rb')
        "#{cname}##{method}"
      else
        ""
      end
    end

    # Searches through a controller's definition to find which method is rendering
    # a given partial. Multiple method names may be returned.
    #
    # A root is needed to provide flexibility so the controller file can be opened
    # regardless of the current working directory. Normally paths are just used
    # for their conventions, but in the controller's case here, the path needs
    # to actually point to a file relative to the current working directory.
    def self.methods_that_render(partial_path, controller_path, rails_root = PartialFinder.default_root)
      if is_partial?(partial_path) && is_controller?(controller_path)
        full_c_path = "#{rails_root}/#{controller_path}"
        fragments = File.read(full_c_path).split /def (.+?)$/
        ref = path_to_ref(partial_path)
        matches = []

        fragments.each.with_index do |fr,i|
          matches << fragments[i-1] if fr.match ref
        end

        matches
      else
        ""
      end
    end
  end
end
