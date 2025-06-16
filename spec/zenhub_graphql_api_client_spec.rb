require "zenhub_graphql_api_client"
require "zenhub_graphql_api_client/version"

RSpec.describe ZenhubGraphQLApiClient do
  it "has a version number" do
    expect(ZenhubGraphQLApiClient::VERSION).not_to be nil
  end

  it "creates a client" do
    client = ZenhubGraphQLApiClient::Client.new(token: "test_token")
    expect(client).to be_a(ZenhubGraphQLApiClient::Client)
  end
end
