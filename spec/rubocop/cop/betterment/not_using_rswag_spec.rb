# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::NotUsingRswag, :config do
  let(:error_message) do
    'API tests should use documented using rswag and not the built in `get`, `post`, `put`, `patch`, `delete` methods'
  end

  %w(get put patch post delete).each do |method_name|
    it "rejects using the built in #{method_name} method in a test" do
      expect_offense(<<~RUBY)
        RSpec.describe MyApiController do
          it 'returns ok status with expected response' do
            get "/api/widgets/1"
            ^^^^^^^^^^^^^^^^^^^^ #{error_message}
            expect(response).to have_http_status :ok
            expect(response_json).to eq accepted_response.as_json
          end
        end
      RUBY
    end

    it "rejects using the built in #{method_name} method in a shared method" do
      expect_offense(<<~RUBY)
        RSpec.describe MyApiController do
          def make_get_request
            get "/api/widgets/1"
            ^^^^^^^^^^^^^^^^^^^^ #{error_message}
          end

          it 'returns ok status with expected response' do
            make_get_request

            expect(response).to have_http_status :ok
            expect(response_json).to eq accepted_response.as_json
          end
        end
      RUBY
    end

    it "rejects using the built in #{method_name} method in a before block" do
      expect_offense(<<~RUBY)
        RSpec.describe MyApiController do
          before do
            get "/api/widgets/1"
            ^^^^^^^^^^^^^^^^^^^^ #{error_message}
          end

          it 'returns ok status with expected response' do
            expect(response).to have_http_status :ok
            expect(response_json).to eq accepted_response.as_json
          end
        end
      RUBY
    end

    it "accepts using the rswag #{method_name} method in the example setup" do
      expect_no_offenses(<<~RUBY)
        RSpec.describe MyApiController do
          path "/api/widgets/1" do
            get 'shows a foo widget' do

              it 'returns ok status with expected response' do
                expect(response).to have_http_status :ok
                expect(response_json).to eq accepted_response.as_json
              end
            end
          end
        end
      RUBY
    end
  end
end
