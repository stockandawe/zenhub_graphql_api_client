# ZenHub Client

A Ruby gem for interacting with the ZenHub GraphQL API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zenhub_graphql_api_client'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install zenhub_graphql_api_client
```

## Usage

```ruby
# Initialize the client
client = ZenhubGraphQLApiClient::Client.new('your_zenhub_api_key')

# Get workspace ID
workspace_id = client.get_workspace_id('your_workspace_name')

# Get workspace info
workspace_info = client.get_workspace_info(workspace_id)

# Get workspace issues
workspace_issues = client.get_workspace_issues(workspace_id)

# Get workspace sprints
workspace_sprints = client.get_workspace_sprints(workspace_id)

# Get workspace epics
epics = client.get_workspace_epics('your_workspace_id')

# Get epic estimate
epic_data = client.get_epic_estimate('your_epic_id')

# Get issue info
issue_data = client.get_issue_info('your_repository_id', 'your_issue_number')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
