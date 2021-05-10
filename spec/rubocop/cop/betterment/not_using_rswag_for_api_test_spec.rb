require 'spec_helper'

describe RuboCop::Cop::Betterment::NotUsingRswagForApiTest, :config do
  it 'rejects a request spec using the built in get method' do
    inspect_source(<<-DEF)
      RSpec.describe MyApiController do
         it 'returns ok status with expected response' do
           get "/api/widgets/1`"

           expect(response).to have_http_status :ok
           expect(response_json).to eq accepted_response.as_json
         end
      end
    DEF

    expect(cop.offenses.size).to be(1)
    expect(cop.offenses.map(&:line)).to eq([3])
    expect(cop.offenses.first.message).to include('Api tests should use https://github.com/rswag/rswag')
  end
end
