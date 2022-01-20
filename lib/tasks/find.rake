namespace :partial_finder do
  desc "Outputs routes that render a given partial."
  task :find, [:path] => [:environment] do |task_name, args|
    puts PartialFinder::Runner.new(args[:path]).print
  end
end
