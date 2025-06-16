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

# Get epic estimate
epic_data = client.get_epic_estimate('your_epic_id')

# Get epics from workspace
epics = client.get_epics_from_workspace('your_workspace_id')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).