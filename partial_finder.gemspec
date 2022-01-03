
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "partial_finder/version"

Gem::Specification.new do |spec|
  spec.name          = "partial_finder"
  spec.version       = PartialFinder::VERSION
  spec.authors       = ["Jeremy Baker"]
  spec.email         = ["jeremy.baker@negotiatus.com"]

  spec.summary       = %q{Finds app routes given a partial file name.}
  spec.description   = %q{Adds a rake task that accepts a view partial file name and outputs the render chain along with best guesses as to the routes used to render the partial.}
  spec.homepage      = "https://github.com/Negotiatus/partial_finder"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/Negotiatus/partial_finder"
    spec.metadata["changelog_uri"] = "https://github.com/Negotiatus/partial_finder"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "byebug"
  spec.add_dependency 'activesupport'
  spec.add_dependency 'colorize'
end
