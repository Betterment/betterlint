# frozen_string_literal: true

# Appraisals

# To update Appraisal-generated gemfiles/*.gemfile run:
#   BUNDLE_GEMFILE=appraisal_root.gemfile bundle update
#   BUNDLE_GEMFILE=appraisal_root.gemfile appraisal update
#   BUNDLE_GEMFILE=gemfiles/style.gemfile bundle exec rubocop -A --only Style/FrozenStringLiteralComment,Layout/EmptyLineAfterMagicComment

appraise "style" do
  gem "mutex_m", "~> 0.2"
  gem "rails", ">= 6.1"
  gem "rake", ">= 13"
  gem "rubocop-packaging", "~> 0.5", ">= 0.5.2"
  # Skip some bad releases of standard
  gem "standard", ">= 1.35.1", "!= 1.41.1", "!= 1.42.0"
  gem "stringio", "~> 3.0"
end

# Compat: Ruby >= 2.5
# Test Matrix:
#   - Ruby 2.5
#   - Ruby 2.6
#   - Ruby 2.7
#   + Ruby 3.0
appraise "rails-6-1" do
  gem "mutex_m", "~> 0.2"
  gem "rails", "~> 6.1.7.10"
  gem "rake", ">= 13"
  gem "rspec-rails"
  gem "stringio", "~> 3.0"
end

# Compat: Ruby >= 2.7
# Test Matrix:
#   - Ruby 2.7
#   + Ruby 3.0
#   + Ruby 3.1
appraise "rails-7-0" do
  gem "mutex_m", "~> 0.2"
  gem "rails", "~> 7.0.8", ">= 7.0.8.7"
  gem "rake", ">= 13"
  gem "rspec-rails"
  gem "stringio", "~> 3.0"
end

# Compat: Ruby >= 2.7
# Test Matrix:
#   - Ruby 2.7
#   + Ruby 3.0
#   + Ruby 3.1
#   + Ruby 3.2
appraise "rails-7-1" do
  gem "mutex_m", "~> 0.2"
  gem "rails", "~> 7.1.5", ">= 7.1.5.1"
  gem "rake", ">= 13"
  gem "rspec-rails"
  gem "stringio", "~> 3.0"
end

# Compat: Ruby >= 3.1
# Test Matrix:
#   + Ruby 3.1
#   + Ruby 3.2
#   + Ruby 3.3
appraise "rails-7-2" do
  gem "mutex_m", "~> 0.2"
  gem "rails", "~> 7.2.2", ">= 7.2.2.1"
  gem "rake", ">= 13"
  gem "rspec-rails"
  gem "stringio", "~> 3.0"
end

# Compat: Ruby >= 3.2
# Test Matrix:
#   + Ruby 3.2
#   + Ruby 3.3
#   + ruby-head
appraise "rails-8-0" do
  gem "mutex_m", "~> 0.2"
  gem "rails", "~> 8.0.1"
  gem "rake", ">= 13"
  gem "rspec-rails"
  gem "stringio", "~> 3.0"
end
