describe RuboCop::Cop::Betterment::DynamicParams, :config do
  let(:offense_dynamic_parameter) do
    <<~MSG.freeze
      Parameter names accessed dynamically, cannot determine safeness. Please inline the keys explicitly when calling `permit` or when accessing `params` like a hash.

      See here for more information on this error:
      https://github.com/Betterment/betterlint/blob/main/README.md#bettermentdynamicparams
    MSG
  end

  context 'when creating or updating a model' do
    it 'registers an offense when parameter names are accessed dynamically' do
      inspect_source(<<~RUBY)
        class Application
          def create
            dynamic_field = :user_id
            params.require(:user).permit(dynamic_field)
            params.permit(dynamic_field)
            params[dynamic_field]
          end
        end
      RUBY

      expect(cop.offenses.size).to be(3)
      expect(cop.offenses.map(&:line)).to eq([4, 5, 6])
      expect(cop.highlights.uniq).to eq(['dynamic_field'])
      expect(cop.messages.uniq).to eq([offense_dynamic_parameter])
    end

    it 'does not register an offense when accessing static parameter names' do
      expect_no_offenses(<<~RUBY)
        class Application
          def create
            params.require(:user).permit(:user_id)
            params.permit(:user_id)
            params[:user_id]
          end
        end
      RUBY
    end

    it 'does not register an offense when accessing non-params objects dynamically' do
      expect_no_offenses(<<~RUBY)
        class Application
          def create
            dynamic_field = :something
            not_params[dynamic_field]
            also_not_params.permit(:user_id)
            still_not_params.require(:user).fetch(dynamic_field)
            really_not_params_I_swear[dynamic_field]
          end
        end
      RUBY
    end
  end
end
