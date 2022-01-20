namespace :partial_finder do
  desc "Same as the find task, but prints out intermediate steps as well."
  task :debug, [:path] => [:environment] do |task_name, args|
    puts PartialFinder::Runner.new(args[:path]).debug
  end
end
