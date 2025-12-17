# frozen_string_literal: true

require 'lint_roller'
require_relative 'betterlint/version'

module Betterlint
  class Plugin < LintRoller::Plugin
    def about
      LintRoller::About.new(
        name: 'betterlint',
        version: VERSION,
        homepage: 'https://github.com/Betterment/betterlint',
        description: 'Shared rubocop configuration for Betterment Rails apps/engines.',
      )
    end

    def supported?(context)
      context.engine == :rubocop
    end

    def rules(_context)
      LintRoller::Rules.new(
        type: :path,
        config_format: :rubocop,
        value: File.expand_path('../config/default.yml', __dir__),
      )
    end
  end
end
