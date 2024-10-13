require 'rails_helper'

RSpec.describe Auth::SignUp do
  let(:params) do
    {
      email: 'johndoe@example.com',
      password: 'password',
      first_name: 'John',
      last_name: 'Doe'
    }
  end

  describe 'email' do
    context 'when email is already taken' do
      before do
        create(:user, email: params[:email])
      end

      it 'raises an error' do
        expect { described_class.call(params) }.to raise_error(Exceptions::UnprocessableEntityError)
      end

      it 'raises an error with detailed code' do
        begin
          described_class.call(params)
        rescue Exceptions::UnprocessableEntityError => e
          expect(e.detailed_code).to eq('EMAIL_TAKEN')
        end
      end
    end

    context 'when email is blank' do
      before do
        params[:email] = ''
      end

      it 'raises an error' do
        expect { described_class.call(params) }.to raise_error(Exceptions::UnprocessableEntityError)
      end

      it 'raises an error with detailed code' do
        begin
          described_class.call(params)
          describe 'password' do
            context 'when password is too short' do
              before do
                params[:password] = 'short'
              end

              it 'raises an error' do
                expect { described_class.call(params) }.to raise_error(Exceptions::UnprocessableEntityError)
              end

              it 'raises an error with detailed code' do
                begin
                  described_class.call(params)
                rescue Exceptions::UnprocessableEntityError => e
                  expect(e.detailed_code).to eq('SHORT_PASSWORD')
                end
              end
            end
          end
        rescue Exceptions::UnprocessableEntityError => e
          expect(e.detailed_code).to eq('EMAIL_REQUIRED')
        end
      end

      context 'when email is invalid' do
        before do
          params[:email] = 'invalid'
        end

        it 'raises an error' do
          expect { described_class.call(params) }.to raise_error(Exceptions::UnprocessableEntityError)
        end

        it 'raises an error with detailed code' do
          begin
            described_class.call(params)
          rescue Exceptions::UnprocessableEntityError => e
            expect(e.detailed_code).to eq('INVALID_EMAIL')
          end
        end
      end
    end
  end

  describe 'first name' do
    context 'when first name is blank' do
      before do
        params[:first_name] = ''
      end

      it 'raises an error' do
        expect { described_class.call(params) }.to raise_error(Exceptions::UnprocessableEntityError)
      end

      it 'raises an error with detailed code' do
        begin
          described_class.call(params)
        rescue Exceptions::UnprocessableEntityError => e
          expect(e.detailed_code).to eq('FIRST_NAME_REQUIRED')
        end
      end
    end

    context 'when first name is too short' do
      before do
        params[:first_name] = 'J'
      end

      it 'raises an error' do
        expect { described_class.call(params) }.to raise_error(Exceptions::UnprocessableEntityError)
      end

      it 'raises an error with detailed code' do
        begin
          described_class.call(params)
        rescue Exceptions::UnprocessableEntityError => e
          expect(e.detailed_code).to eq('FIRST_NAME_SHORT')
        end
      end
    end
  end

  describe 'last name' do
    context 'when last name is blank' do
      before do
        params[:last_name] = ''
      end

      it 'raises an error' do
        expect { described_class.call(params) }.to raise_error(Exceptions::UnprocessableEntityError)
      end

      it 'raises an error with detailed code' do
        begin
          described_class.call(params)
        rescue Exceptions::UnprocessableEntityError => e
          expect(e.detailed_code).to eq('LAST_NAME_REQUIRED')
        end
      end
    end

    context 'when last name is too short' do
      before do
        params[:last_name] = 'D'
      end

      it 'raises an error' do
        expect { described_class.call(params) }.to raise_error(Exceptions::UnprocessableEntityError)
      end

      it 'raises an error with detailed code' do
        begin
          described_class.call(params)
        rescue Exceptions::UnprocessableEntityError => e
          expect(e.detailed_code).to eq('LAST_NAME_SHORT')
        end
      end
    end
  end
  context 'when params are valid' do
    it 'creates a user' do
      result = described_class.call(params).result
      expect(result[:user]).to be_persisted
    end

    it 'returns a token' do
      result = described_class.call(params).result
      expect(result[:token]).to be_present
    end

    it 'returns a token with the correct user id' do
      result = described_class.call(params).result
      decoded_token = Jwt::Decode.call(result[:token]).result
      expect(decoded_token[:user_id]).to eq(result[:user].id)
    end

    it 'returns the correct user' do
      result = described_class.call(params).result
      user = result[:user]
      expect(user.email).to eq(params[:email])
      expect(user.first_name).to eq(params[:first_name])
      expect(user.last_name).to eq(params[:last_name])
    end
  end
end
