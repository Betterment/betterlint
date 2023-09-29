require 'spec_helper'

describe RuboCop::Cop::Betterment::Utils::HardcodedAttribute do
  include RuboCop::AST::Sexp

  subject { described_class.new(find_attribute) }

  context "when the attribute is not within a let" do
    let(:source) { 'FactoryBot.create(:user, id: 42)' }

    it "is not correctable" do
      expect(subject).not_to be_correctable
    end
  end

  context "when the attribute is passed to create_list" do
    let(:source) do
      <<~RUBY
        RSpec.describe User do
          let(:user) { FactoryBot.create_list(:user, foo_id: 42) }
        end
      RUBY
    end

    it "is not correctable" do
      expect(subject).not_to be_correctable
    end
  end

  context "when the attribute is a foreign key within a let block" do
    let(:source) do
      <<~RUBY
        RSpec.describe User do
          let(:user) { FactoryBot.create(:user, foo_id: 42) }
          specify { 42 }
          specify { "Foo 42" }
        end
      RUBY
    end

    it "is not correctable" do
      expect(subject).not_to be_correctable
    end
  end

  context "when the attribute is an ID within a let block" do
    let(:source) do
      <<~RUBY
        RSpec.describe User do
          let(:user) { FactoryBot.create(:user, id: 42) }
          specify { 42 }
          specify { 'User 42' }
        end
      RUBY
    end

    it "is correctable" do
      expect(subject).to be_correctable
    end

    it "finds integer references" do
      expect(subject.enum_for(:each_integer_reference)).to contain_exactly(s(:int, 42))
    end

    it "finds string references" do
      expect(subject.enum_for(:each_string_reference)).to contain_exactly(s(:str, "User 42"))
    end

    it "finds ranges of string references" do
      reference = subject.enum_for(:each_string_reference).first
      range = subject.enum_for(:each_range_within_string, reference).first
      expect(range).to have_attributes(begin_pos: 108, end_pos: 110)
    end
  end

  def find_attribute
    ast = RuboCop::AST::ProcessedSource.new(source, RUBY_VERSION.to_f).ast
    ast.each_descendant(:pair).first
  end
end
