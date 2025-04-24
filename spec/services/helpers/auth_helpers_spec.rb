require 'rails_helper'

RSpec.describe Helpers::AuthHelpers do
  class TestClass
    include Helpers::AuthHelpers
  end

  let(:user) { create(:user) }

  describe '#generate_token' do
    it 'generates a token' do
      expect(TestClass.new.generate_token(user)).to be_a(String)
    end

    it 'raises an error if the JWT_SECRET environment variable is not set' do
      allow(ENV).to receive(:fetch).with('JWT_SECRET', nil).and_return(nil)
      expect { TestClass.new.generate_token(user) }.to raise_error(Exceptions::InternalServerError)
    end

    it 'returns the JWT_SECRET environment variable if it is set' do
      allow(ENV).to receive(:fetch).with('JWT_SECRET', nil).and_return('secret')
      expect(TestClass.new.jwt_secret).to eq('secret')
    end
  end
end
