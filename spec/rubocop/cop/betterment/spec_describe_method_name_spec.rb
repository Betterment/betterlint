# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Betterment::SpecDescribeMethodName, :config do
  context 'when the class describe holds method describes' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Invoice do
          let(:account) { create(:account, :delinquent) }

          describe "#total" do
            it "sums the line items" do
              expect(invoice.total).to eq 100
            end
          end

          describe ".open" do
            context "when the invoice is paid" do
              it "excludes the invoice" do
                expect(described_class.open).to be_empty
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when the outer describe is a string' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        RSpec.describe "Invoice" do
                       ^^^^^^^^^ Label the outer `describe` with the class constant, not a string.
          describe "#total" do
            it "sums the line items" do
              expect(invoice.total).to eq 100
            end
          end
        end
      RUBY
    end
  end

  context 'when the outer describe is a bare describe with a string' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        describe "some behaviour" do
                 ^^^^^^^^^^^^^^^^ Label the outer `describe` with the class constant, not a string.
          describe "#total" do
            it "sums the line items" do
              expect(invoice.total).to eq 100
            end
          end
        end
      RUBY
    end
  end

  context 'when an example is not inside a method describe' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        RSpec.describe Invoice do
          it "sums the line items" do
          ^^^^^^^^^^^^^^^^^^^^^^^^ Put examples inside a `describe` labeled with a method name, such as `"#instance_method"` or `".class_method"`.
            expect(invoice.total).to eq 100
          end

          context "when the account is delinquent" do
            specify { expect(invoice.total).to eq 200 }
            ^^^^^^^ Put examples inside a `describe` labeled with a method name, such as `"#instance_method"` or `".class_method"`.
          end
        end
      RUBY
    end
  end

  context 'when a context block wraps the method describe' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        RSpec.describe Invoice do
          context "when the account is delinquent" do
            describe "#total" do
            ^^^^^^^^^^^^^^^^^ Put the method `describe` directly inside the class `describe`, and share setup with `let` or `before`.
              it "adds the late fee" do
                expect(invoice.total).to eq 100
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when a nested class describe holds the method describe' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        RSpec.describe Invoice do
          describe Invoice::Item do
            describe "#total" do
            ^^^^^^^^^^^^^^^^^ Describe one class in each spec file, and put the method `describe` directly inside the outer `describe`.
              it "sums the line items" do
                expect(item.total).to eq 100
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when the examples live in a shared example group' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.shared_examples "a billable record" do
          it "is billable" do
            expect(record).to be_billable
          end
        end
      RUBY
    end
  end

  context 'when a shared example group is nested in a class describe' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Invoice do
          shared_examples "a billable record" do
            it "is billable" do
              expect(record).to be_billable
            end
          end

          describe "#total" do
            it_behaves_like "a billable record"
          end
        end
      RUBY
    end
  end

  context 'when the describe carries metadata' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Invoice, type: :model do
          describe "#total" do
            it "sums the line items" do
              expect(invoice.total).to eq 100
            end
          end
        end
      RUBY
    end
  end

  context 'when the method describe uses a double colon separator' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        RSpec.describe Invoice do
          describe "::open" do
            it "excludes paid invoices" do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Put examples inside a `describe` labeled with a method name, such as `"#instance_method"` or `".class_method"`.
              expect(described_class.open).to be_empty
            end
          end
        end
      RUBY
    end
  end

  context 'when the outer describe is a namespaced constant' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Invoice::Item do
          describe "#total" do
            it "sums the line items" do
              expect(item.total).to eq 100
            end
          end
        end
      RUBY
    end
  end

  context 'when the method label carries trailing words' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Invoice do
          describe "#total with tax" do
            it "adds the tax" do
              expect(invoice.total).to eq 110
            end
          end
        end
      RUBY
    end
  end

  context 'when the describe has an explicit top level RSpec receiver' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        ::RSpec.describe Invoice do
          describe "#total" do
            it "sums the line items" do
              expect(invoice.total).to eq 100
            end
          end
        end
      RUBY
    end
  end

  context 'when a method with an example name has a receiver' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        RSpec.describe Invoice do
          before do
            report.scenario "a name that is not an example"
          end

          describe "#total" do
            it "sums the line items" do
              expect(invoice.total).to eq 100
            end
          end
        end
      RUBY
    end
  end

  context 'when the describe has no block' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        RSpec.describe "Invoice"
                       ^^^^^^^^^ Label the outer `describe` with the class constant, not a string.
      RUBY
    end
  end

  context 'when a describe belongs to another library' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Minitest.describe "Invoice" do
          it "sums the line items" do
            expect(invoice.total).to eq 100
          end
        end
      RUBY
    end
  end

  context 'when a describe inside the class describe is not a method label' do
    it 'registers an offense for the examples' do
      expect_offense(<<~RUBY)
        RSpec.describe Invoice do
          describe "totalling" do
            it "sums the line items" do
            ^^^^^^^^^^^^^^^^^^^^^^^^ Put examples inside a `describe` labeled with a method name, such as `"#instance_method"` or `".class_method"`.
              expect(invoice.total).to eq 100
            end
          end
        end
      RUBY
    end
  end
end
