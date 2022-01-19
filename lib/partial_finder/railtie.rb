require 'rails'

module PartialFinder
  class Railtie < Rails::Railtie
    railtie_name :partial_finder

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/../tasks/**/*.rake").each{ |f| load f }
    end
  end
end
