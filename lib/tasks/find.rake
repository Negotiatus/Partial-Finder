namespace :partial_finder do
  desc "Output routes that render a given partial. Usage: rake partial_finder:find\\['path/to/_partial.html.erb'\\]"
  task :find, [:path] => [:environment] do |task_name, args|
    PartialFinder::Runner.new(args[:path]).print_to_console
  end
end
