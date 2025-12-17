# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'betterlint/version'

Gem::Specification.new do |s|
  s.name = "betterlint"
  s.version = Betterlint::VERSION
  s.authors = ["Development"]
  s.email = ["development@betterment.com"]
  s.summary = "Betterment rubocop configuration"
  s.description = "Betterment rubocop configuration"
  s.license = "MIT"

  s.homepage = "https://github.com/Betterment/#{s.name}"
  s.metadata["homepage_uri"] = s.homepage
  s.metadata["source_code_uri"] = "#{s.homepage}/tree/v#{s.version}"
  s.metadata["changelog_uri"] = "#{s.homepage}/blob/v#{s.version}/CHANGELOG.md"
  s.metadata["bug_tracker_uri"] = "#{s.homepage}/issues"
  s.metadata["documentation_uri"] = "https://www.rubydoc.info/gems/#{s.name}/#{s.version}"
  s.metadata['rubygems_mfa_required'] = 'true'
  s.metadata['default_lint_roller_plugin'] = 'Betterlint::Plugin'

  s.files = Dir["README.md", "STYLEGUIDE.md", "config/*.yml", "lib/**/*.rb"]

  s.required_ruby_version = ">= 3.0"

  s.add_dependency "lint_roller", "~> 1.1"
  s.add_dependency "rubocop", "~> 1.82"
  s.add_dependency "rubocop-capybara", "~> 2.22"
  s.add_dependency "rubocop-factory_bot", "~> 2.28"
  s.add_dependency "rubocop-graphql", ["~> 1.5", ">= 1.5.6"]
  s.add_dependency "rubocop-performance", "~> 1.26"
  s.add_dependency "rubocop-rails", "~> 2.34"
  s.add_dependency "rubocop-rake", "~> 0.7"
  s.add_dependency "rubocop-rspec", "~> 3.8"
  s.add_dependency "rubocop-rspec_rails", "~> 2.32"
end
