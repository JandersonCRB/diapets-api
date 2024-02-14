require 'rails_helper'

RSpec.describe "Base", type: :request do
  it "returns hello world" do
    get "/api/v1"
    expect(response).to have_http_status(200)
    expect(JSON.parse(response.body)).to eq({ "hello" => "world" })
  end
end