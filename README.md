# PartialFinder

As Rails apps grow, partial usage and templates get increasingly complicated. PartialFinder adds rake tasks to your Rails app to help you track down the various ways that a given parial may be rendered. You can provide it a partial path and it will output all of the routes and controllers that serve it, along with the intermediate files.

Usage: `rake partial_finder:find\\['path/to/_partial.html.erb'\\]`

## Installation

Add this line to your application's Gemfile under the development group:

```ruby
gem 'partial_finder', "~> 0.1", git: "https://github.com/Negotiatus/Partial-Finder.git"
```

And then execute:

    $ bundle install

## Usage

To view this help manual outside of the README, run `bundle exec rake partial_finder:help`.

PartialFinder adds two rake tasks to help track down partial usage:

Task: Find
Usage: `rake partial_finder:find\\['path/to/_partial.html.erb'\\]`
Outputs all render chains and tries to match each partial with any controllers and routes that eventually render it.

Task: Debug
Usage: `rake partial_finder:debug\\['path/to/_partial.html.erb'\\]`
Contains the same output as Find but with additional intermediate steps that can be used to help validate the final results.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/partial_finder. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PartialFinder project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/partial_finder/blob/master/CODE_OF_CONDUCT.md).
