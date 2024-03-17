require 'rails_helper'

RSpec.describe Auth::Login, type: :service do
  context 'when user is found' do
    let(:user) { create(:user, email: 'johndoe@example.com', password: 'password') }
    let(:params) { { email: user.email, password: user.password } }

    context 'when password is valid' do
      it 'returns a token' do
        result = described_class.call(params).result
        expect(result).to include(:token)
      end

      it 'returns a user' do
        result = described_class.call(params).result
        expect(result).to include(:user)
      end
    end

    context 'when password is invalid' do
      it 'returns an error' do
        params[:password] = 'invalid_password'
        expect do
          described_class.call(params)
        end.to raise_error(Exceptions::InvalidCredentialsError)
      end
    end

    context 'when JWT_SECRET ENV variable is not set' do
      it 'returns an error' do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with('JWT_SECRET', nil).and_return(nil)
        expect do
          described_class.call(params)
        end.to raise_error(Exceptions::InternalServerError)
      end
    end
  end

  context 'when user is not found' do
    it 'returns an error' do
      expect do
        described_class.call(email: 'johndoe@example.com', password: 'password')
      end.to raise_error(Exceptions::NotFoundError)
    end
  end
end