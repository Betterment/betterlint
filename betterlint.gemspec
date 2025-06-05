# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = "betterlint"
  s.version = "1.21.0"
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

  s.files = Dir["README.md", "STYLEGUIDE.md", "config/*.yml", "lib/**/*.rb"]

  s.required_ruby_version = ">= 3.0"

  s.add_dependency "rubocop", "~> 1.71"
  s.add_dependency "rubocop-graphql", "~> 1.5"
  s.add_dependency "rubocop-performance", "~> 1.23"
  s.add_dependency "rubocop-rails", "~> 2.29"
  s.add_dependency "rubocop-rake", "~> 0.6"
  s.add_dependency "rubocop-rspec", "~> 2.29"
end
