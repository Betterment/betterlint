require 'spec_helper'

describe RuboCop::Cop::Betterment::ServerErrorAssertion, :config do
  let(:error_message) { 'Do not assert on 5XX statuses. Use a semantic status (e.g., 403, 422, etc.) or treat them as bugs (omit tests).' }

  it 'registers no offense for numeric semantic statuses' do
    expect_no_offenses('expect(response).to have_http_status(200)')
    expect_no_offenses('expect(response).to have_http_status(422)')
    expect_no_offenses('expect(response).to have_http_status(301)')
  end

  it 'registers no offense for symbolic semantic statuses' do
    expect_no_offenses('expect(response).to have_http_status(:unprocessable_entity)')
    expect_no_offenses('expect(response).to have_http_status(:ok)')
    expect_no_offenses('expect(response).to have_http_status(:created)')
  end

  it 'registers no offense for string semantic statuses' do
    expect_no_offenses('expect(response).to have_http_status("unprocessable_entity")')
    expect_no_offenses('expect(response).to have_http_status("ok")')
    expect_no_offenses('expect(response).to have_http_status("created")')
  end

  (500..599).each do |status|
    it "registers an offense for numeric HTTP #{status} status" do
      expect_offense(<<-RUBY)
      expect(response).to have_http_status(#{status})
                          ^^^^^^^^^^^^^^^^^^^^^ #{error_message}
      RUBY
    end
  end

  it 'registers an offense for :internal_server_error' do
    expect_offense(<<-RUBY)
      expect(response).to have_http_status(:internal_server_error)
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{error_message}
    RUBY
  end

  it 'registers an offense for :not_implemented' do
    expect_offense(<<-RUBY)
      expect(response).to have_http_status(:not_implemented)
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{error_message}
    RUBY
  end

  it 'registers an offense for :bad_gateway' do
    expect_offense(<<-RUBY)
      expect(response).to have_http_status(:bad_gateway)
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{error_message}
    RUBY
  end

  it 'registers an offense for :service_unavailable' do
    expect_offense(<<-RUBY)
      expect(response).to have_http_status(:service_unavailable)
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{error_message}
    RUBY
  end

  it 'registers an offense for :gateway_timeout' do
    expect_offense(<<-RUBY)
      expect(response).to have_http_status(:gateway_timeout)
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{error_message}
    RUBY
  end

  it 'registers an offense for :http_version_not_supported' do
    expect_offense(<<-RUBY)
      expect(response).to have_http_status(:http_version_not_supported)
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{error_message}
    RUBY
  end

  it 'registers an offense for :insufficient_storage' do
    expect_offense(<<-RUBY)
      expect(response).to have_http_status(:insufficient_storage)
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{error_message}
    RUBY
  end

  it 'registers an offense for :not_extended' do
    expect_offense(<<-RUBY)
      expect(response).to have_http_status(:not_extended)
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{error_message}
    RUBY
  end

  it 'registers an offense for "internal_server_error"' do
    expect_offense(<<-RUBY)
      expect(response).to have_http_status("internal_server_error")
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{error_message}
    RUBY
  end

  it 'registers an offense for "not_implemented"' do
    expect_offense(<<-RUBY)
      expect(response).to have_http_status("not_implemented")
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{error_message}
    RUBY
  end

  it 'registers an offense for "bad_gateway"' do
    expect_offense(<<-RUBY)
      expect(response).to have_http_status("bad_gateway")
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{error_message}
    RUBY
  end

  it 'registers an offense for "service_unavailable"' do
    expect_offense(<<-RUBY)
      expect(response).to have_http_status("service_unavailable")
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{error_message}
    RUBY
  end

  it 'registers an offense for "gateway_timeout"' do
    expect_offense(<<-RUBY)
      expect(response).to have_http_status("gateway_timeout")
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{error_message}
    RUBY
  end

  it 'registers an offense for "http_version_not_supported"' do
    expect_offense(<<-RUBY)
      expect(response).to have_http_status("http_version_not_supported")
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{error_message}
    RUBY
  end

  it 'registers an offense for "insufficient_storage"' do
    expect_offense(<<-RUBY)
      expect(response).to have_http_status("insufficient_storage")
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{error_message}
    RUBY
  end

  it 'registers an offense for "not_extended"' do
    expect_offense(<<-RUBY)
      expect(response).to have_http_status("not_extended")
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{error_message}
    RUBY
  end
end
