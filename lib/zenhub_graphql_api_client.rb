require 'net/http'
require 'uri'
require 'json'
require 'csv'

module ZenhubGraphQLApiClient
  class Client
    attr_reader :api_key, :api_url

    def initialize(api_key_string, api_url = 'https://api.zenhub.com/public/graphql')
      @api_key = api_key_string
      @api_url = api_url
    end

    def get_epic_total_estimate(epic_id)
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

      response_body = execute_query(query, { epicId: epic_id })

      # Check for errors in the response
      if response_body['errors']
        puts "Error fetching data from Zenhub: #{response_body['errors'].map { |e| e['message'] }.join(', ')}"
        return nil # Or raise an exception
      elsif response_body['data'] && response_body['data']['node'] && response_body['data']['node']['childIssues']
        epic_data = response_body['data']['node']
        child_issues = epic_data['childIssues']['nodes']

        total_estimate = 0
        child_issues.each do |issue|
          estimate_value = issue['estimate'] ? issue['estimate']['value'] : 0
          total_estimate += estimate_value
        end

        return total_estimate
      else
        puts "Could not retrieve epic data for ID: #{epic_id}. Please check the Epic ID and API key."
        puts "Response body: #{response_body}"
        return nil # Or raise an exception
      end
    end

    def get_workspace_epics(workspace_id)
      query = <<~GRAPHQL
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

      response_body = execute_query(query, { workspaceId: workspace_id })

      if response_body['errors']
        puts "Error fetching epics: #{response_body['errors'].map { |e| e['message'] }.join(', ')}"
        return nil
      end

      # Adapt the response structure to match the expected data path
      if response_body['data'] && response_body['data']['workspace'] && response_body['data']['workspace']['epics'] && response_body['data']['workspace']['epics']['nodes']
        response_body['data']['workspace']['epics']['nodes'].map do |epic|
          {
            id: epic['id'],
            title: epic['issue']['title']
          }
        end
      else
        puts "Could not retrieve epic data for workspace ID: #{workspace_id}."
        puts "Response body: #{response_body}"
        return nil
      end
    end

    def get_issue_info(repository_id, issue_number)
      query = <<~GRAPHQL
        query ($repositoryGhId: Int, $repositoryId: ID, $issueNumber: Int!) {
            issueByInfo(
                repositoryGhId: $repositoryGhId
                repositoryId: $repositoryId
                issueNumber: $issueNumber
            ) {
                    id
                    number
                    title
                    body
                    state
                    estimate {
                      value
                    }
                    sprints (first: 10) {
                      nodes {
                        id
                        name
                      }
                    }
                    labels (first: 10) {
                      nodes {
                        id
                        name
                        color
                      }
                    }
                  }
        }
      GRAPHQL

      response_body = execute_query(query, { repositoryId: repository_id, issueNumber: issue_number })

      if response_body['errors']
        puts "Error fetching issue info: #{response_body['errors'].map { |e| e['message'] }.join(', ')}"
        return nil
      end

      if response_body['data'] && response_body['data']['issueByInfo']
        response_body['data']['issueByInfo']
      else
        puts "Could not retrieve issue info for repositoryId: #{repository_id}, issueNumber: #{issue_number}."
        puts "Response body: #{response_body}"
        return nil
      end
    end

    def get_workspace_info(workspace_id)
      query = <<~GRAPHQL
        query ($workspaceId: ID!) {
            workspace(id: $workspaceId) {
                id
                displayName
                pipelinesConnection {
                  nodes {
                    id
                    name
                  }
                }
            }
        }
      GRAPHQL

      response_body = execute_query(query, { workspaceId: workspace_id })

      if response_body['errors']
        puts "Error fetching workspace: #{response_body['errors'].map { |e| e['message'] }.join(', ')}"
        return nil
      end

      if response_body['data'] && response_body['data']['workspace']
        response_body['data']['workspace']
      else
        puts "Could not retrieve workspace data for ID: #{workspace_id}."
        puts "Response body: #{response_body}"
        return nil
      end
    end

    def get_workspace_id(workspace_name)
      query = <<~GRAPHQL
        query searchWorkspaces($workspaceName: String!) {
          viewer {
            id
            searchWorkspaces(query: $workspaceName) {
              nodes {
                id
                name
                repositoriesConnection {
                  nodes {
                    id
                    name
                  }
                }
              }
            }
          }
        }
      GRAPHQL

      variables = { workspaceName: workspace_name }
      response_body = execute_query(query, variables)

      if response_body['errors']
        puts "Error searching for workspace: #{response_body['errors'].map { |e| e['message'] }.join(', ')}"
        return nil
      end

      if response_body['data'] &&
         response_body['data']['viewer'] &&
         response_body['data']['viewer']['searchWorkspaces'] &&
         response_body['data']['viewer']['searchWorkspaces']['nodes'] &&
         !response_body['data']['viewer']['searchWorkspaces']['nodes'].empty?

        found_workspace = response_body['data']['viewer']['searchWorkspaces']['nodes'].find do |node|
          node['name'] == workspace_name
        end

        if found_workspace
          return found_workspace['id']
        else
          puts "Workspace with name '#{workspace_name}' not found."
          return nil
        end
      else
        puts "Could not find workspace with name '#{workspace_name}'."
        puts "Response body: #{response_body}"
        return nil
      end
    end

    def get_workspace_issues(workspace_id)
      query = <<~GRAPHQL
        query workspaceIssues($workspaceId: ID!) {
          workspace(id: $workspaceId) {
            issues {
              nodes {
                id
                pullRequest
                type
                title
              }
            }
          }
        }
      GRAPHQL

      response_body = execute_query(query, { workspaceId: workspace_id })

      if response_body['errors']
        puts "Error fetching issues: #{response_body['errors'].map { |e| e['message'] }.join(', ')}"
        return nil
      end

      if response_body['data'] && response_body['data']['workspace'] && response_body['data']['workspace']['issues'] && response_body['data']['workspace']['issues']['nodes']
        response_body['data']['workspace']['issues']['nodes']
      else
        puts "Could not retrieve issue data for workspace ID: #{workspace_id}."
        puts "Response body: #{response_body}"
        return nil
      end
    end

    def get_workspace_sprints(workspace_id)
      query = <<~GRAPHQL
        query workspaceSprints($workspaceId: ID!) {
          workspace(id: $workspaceId){
            sprints{
              totalCount
              nodes {
                id
                name
                completedPoints
                closedIssuesCount
                state
                startAt
                endAt
              }
            }
          }
        }
      GRAPHQL

      response_body = execute_query(query, { workspaceId: workspace_id })

      if response_body['errors']
        puts "Error fetching sprint info: #{response_body['errors'].map { |e| e['message'] }.join(', ')}"
        return nil
      end

      if response_body['data'] && response_body['data']['workspace'] && response_body['data']['workspace']['sprints']
        response_body['data']['workspace']['sprints']
      else
        puts "Could not retrieve sprint data for workspace ID: #{workspace_id}."
        puts "Response body: #{response_body}"
        return nil
      end
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

      # Check if the response body is empty
      if response.body.nil? || response.body.empty?
        puts "Error: Received empty response body from Zenhub API."
        return {} # Return an empty hash or handle as appropriate
      end

      begin
        JSON.parse(response.body)
      rescue JSON::ParserError => e
        puts "Error parsing JSON response from Zenhub API: #{e.message}"
        puts "Response body: #{response.body}"
        return {} # Return an empty hash or handle as appropriate
      end
    end
  end
end
