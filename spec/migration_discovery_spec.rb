# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe RuboCop::TargetFinder do
  describe '#find' do
    it 'discovers migrations while excluding generated schemas' do
      Dir.mktmpdir('betterlint-project') do |project|
        project = File.realpath(project)
        FileUtils.mkdir_p(File.join(project, 'db/migrate'))
        File.write(File.join(project, '.rubocop.yml'), <<~YAML)
          plugins:
            - betterlint
        YAML

        migration = File.join(project, 'db/migrate/add_nickname.rb')
        schema = File.join(project, 'db/schema.rb')
        named_schema = File.join(project, 'db/animals_schema.rb')
        File.write(migration, '')
        File.write(schema, '')
        File.write(named_schema, '')

        files = Dir.chdir(project) do
          described_class.new(RuboCop::ConfigStore.new).find([], :all_file_types)
        end

        expect(files).to include(migration)
        expect(files).not_to include(schema, named_schema)
      end
    end
  end
end
