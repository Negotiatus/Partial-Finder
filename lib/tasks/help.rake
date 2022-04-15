namespace :partial_finder do
  desc "Display the help menu for Partial Finder"
  task help: :environment do |task_name, args|
    puts PartialFinder::Runner.help
  end
end
