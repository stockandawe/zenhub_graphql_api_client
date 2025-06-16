Gem::Specification.new do |spec|
  spec.name          = "zenhub_graphql_api_client"
  spec.version       = "0.1.0"
  spec.authors       = ["Rutul Davé"]
  spec.email         = ["rutuldave@gmail.com"]

  spec.summary       = "Ruby client for ZenHub GraphQL API"
  spec.description   = "A Ruby gem to interact with ZenHub's GraphQL API"
  spec.homepage      = "https://github.com/stockandawe/zenhub_graphql_api_client"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.files         = Dir["lib/**/*", "LICENSE", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end