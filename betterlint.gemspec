lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = "betterlint"
  s.version = "1.4.9"
  s.authors = ["Development"]
  s.email = ["development@betterment.com"]
  s.summary = "Betterment rubocop configuration"
  s.description = "Betterment rubocop configuration"
  s.license = "MIT"
  s.metadata['rubygems_mfa_required'] = 'true'

  s.files = Dir["README.md", "STYLEGUIDE.md", "config/*.yml", "lib/**/*.rb"]

  s.required_ruby_version = ">= 2.7"

  s.add_dependency "rubocop", "> 1.0"
  s.add_dependency "rubocop-performance"
  s.add_dependency "rubocop-rails"
  s.add_dependency "rubocop-rake"
  s.add_dependency "rubocop-rspec", ">= 2.22"
end
