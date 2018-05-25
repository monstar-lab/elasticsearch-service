# Elasticsearch Service for Vapor

![Swift](https://img.shields.io/badge/swift-4.1-brightgreen.svg)
![Vapor](https://img.shields.io/badge/vapor-3.0-brightgreen.svg)

This library allows you to connect to a Elasticsearch server from your Vapor application, perform searches and get back `Codable`/`Content` results. Currently only searching is supported, not indices nor data manipulation.

## Setup

Add Elasticsearch Service to your `Package.swift` file:

```swift
.package(url: "https://github.com/monstar-lab/elasticsearch-service.git", from: "0.9.0")
```

Register the configuration object and the provider inside your `configure.swift` file:

```swift
let elasticURL = URL(string: "http://localhost:9200")

if let elasticURL = elasticURL {
  let elasticConfig = ElasticsearchConfig(serverURL: elasticURL)
  services.register(elasticConfig)

  try services.register(ElasticsearchProvider())
}
```

## Using the service

After importing `ElasticsearchService` and obtaining instance of `ElasticsearchClient` from your container, you can send your search request (either wrapped in `QueryContainer`, or a simple `[AnyHashable: Any]` in case of complicated queries) and receive search results (again either as custom `Codable` structure, or as an `[AnyHashable: Any]`).

`QueryContainer` and `struct`s that conform to the `Query` protocol allow you to model your queries in a type-safe, Swift-y way. However, not the entirety of Elasticsearch’s query language has been converted, only the most commonly used queries. In case a query you require is missing, feel free to submit a pull request.

```swift
func getSearchHandler(_ req: Request) throws -> Future<[Product]> {
  let elasticClient = try req.make(ElasticsearchClient.self)
  let query = QueryContainer(
    Query(
      Fuzzy(key: "name", value: "bolster", transpositions: true)
    )
  )

  return try elasticClient
    .search(index: "product", query, decodeTo: Product.self)
    .map(to: [Product].self) { result in
      return result.hits.hits.map { $0.source }
    }
}
```

For more examples, please feel free to look into the test suite or comments.

## Known issues

- [ ] `BoolQuery`’s usefulness is significantly hampered by the fact that only one type of queries can be passed as an argument, for example if you pass type `[MatchPhrase]` as an `must` argument, other arguments (`filter`, `mustNot`, etc.) must also be of type `[MatchPhrase]`. If you know how to solve this (type erasure?), a pull request is most appreciated!
- [ ] Indices manipulation is not supported.
- [ ] Data manipulation is not supported.
- [ ] Aggregation is not supported.
