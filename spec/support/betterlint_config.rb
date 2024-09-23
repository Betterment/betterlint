# frozen_string_literal: true

BETTERLINT_CONFIG_PATH = File.expand_path('../../config/default.yml', __dir__)

RSpec.shared_context 'betterlint_config', :betterlint_config do
  include_context 'config'

  let(:betterlint_config) do
    RuboCop::ConfigLoader.load_file(BETTERLINT_CONFIG_PATH)
  end

  let(:cur_cop_config) do
    RuboCop::ConfigLoader
      .default_configuration.for_cop(cop_class)
      .merge(betterlint_config.for_cop(cop_class))
      .merge({
        'Enabled' => true, # in case it is 'pending'
        'AutoCorrect' => true, # in case defaults set it to false
      })
      .merge(cop_config)
  end
end
