require 'net/http'
require 'uri'
require 'json'
require 'csv'

module ZenhubGraphQLApiClient
  class Client
    attr_reader :api_key, :api_url

    def initialize(api_key, api_url = 'https://api.zenhub.com/public/graphql')
      @api_key = api_key
      @api_url = api_url
    end

    def get_epic_estimate(epic_id)
      query = <<-GRAPHQL
        query epicIssues($epicId: ID!) {
          node(id: $epicId) {
            ... on Epic {
              issue {
                title
              }
              childIssues {
                nodes {
                  id
                  title
                  estimate {
                    value
                  }
                }
              }
            }
          }
        }
      GRAPHQL

      response = execute_query(query, { epicId: epic_id })
      # Process response and return structured data
      # ...
    end

    def get_epics_from_workspace(workspace_id)
      query = <<-GRAPHQL
        query epicsFromWorkspace($workspaceId: ID!) {
          workspace(id: $workspaceId) {
            epics {
              nodes {
                id
                issue {
                  title
                }
              }
            }
          }
        }
      GRAPHQL

      execute_query(query, { workspaceId: workspace_id })
    end

    private

    def execute_query(query, variables)
      uri = URI.parse(@api_url)
      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{@api_key}"
      request['Content-Type'] = 'application/json'

      request.body = {
        query: query,
        variables: variables
      }.to_json

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      response = http.request(request)
      JSON.parse(response.body)
    end
  end
end