import Vapor

public final class ElasticsearchClient: Service {
    let httpClient: Client
    let serverURL: URL

    public init(httpClient: Client, serverURL: URL) {
        self.httpClient = httpClient
        self.serverURL = serverURL
    }

    /// Submits a `Codable`-represented query (wrapped in `QueryContainer`) to
    /// Elasticsearch and attempts to decode the response into a `Result<U>`,
    /// where `U` is a `Decodable` type you have to supply.
    ///
    /// Note that even though you’re most likely expecting an array of results
    /// (for example, `Product`s), you should not set the `resultType` argument
    /// to `[Product].self` but rather simply `Product.self`. That’s because
    /// inside the `result.hits.hits` array, the decoded object is a single
    /// object (located under the `source` property), not an array of objects.
    ///
    ///    ```
    ///    let elasticClient = try req.make(ElasticsearchClient.self)
    ///    let query = QueryContainer(
    ///        Query(
    ///            Fuzzy(key: "name", value: "bolster", transpositions: true)
    ///        )
    ///    )
    ///    return try elasticClient
    ///        .search(index: "product", query, decodeTo: Product.self)
    ///        .map(to: [Product].self)
    ///    { result in
    ///        return result.hits.hits.map { $0.source }
    ///    }
    ///    ```
    ///
    /// - Parameters:
    ///     - index: Elasticsearch index to search in.
    ///     - type: Optional Elasticsearch type, defaults to `_doc`.
    ///     - query: A `QueryContainer` to encode into JSON and send to server.
    ///     - resultType: `Decodable` type into which the response should be decoded.
    /// - Returns: Decoded response from Elasticsearch.
    public func search<T: QueryElement, U: Decodable>(
        index: String,
        type: String = "_doc",
        _ query: QueryContainer<T>,
        decodeTo resultType: U.Type
    ) throws -> Future<Result<U>> {
        let url = constructEndpoint(pathComponents: index, type, "_search")
        var headers: HTTPHeaders = [:]

        headers.add(name: .contentType, value: "application/json")

        return try httpClient
            .post(url, headers: headers) { request in
                try request.content.encode(query)
            }
            .decodeResponse(to: Result<U>.self, or: Abort(.badRequest))
    }

    /// Submits a `Codable`-represented query (wrapped in `QueryContainer`) to
    /// Elasticsearch. Instead of decoding the response, it deserializes the
    /// JSON and returns it as `[AnyHashable: Any]` if possible.
    ///
    ///    ```
    ///    let elasticClient = try req.make(ElasticsearchClient.self)
    ///    let query = QueryContainer(
    ///        Query(
    ///            MatchPhrase(key: "name", value: "live")
    ///        )
    ///    )
    ///    return try elasticClient
    ///        .search(index: "product", query)
    ///        .map(to: HTTPStatus.self)
    ///    { result in
    ///        print(result)
    ///        return .ok
    ///    }
    ///    ```
    ///
    /// - Parameters:
    ///     - index: Elasticsearch index to search in.
    ///     - type: Optional Elasticsearch type, defaults to `_doc`.
    ///     - query: A `QueryContainer` to encode into JSON and send to server.
    /// - Returns: `[AnyHashable: Any]` raw response from Elasticsearch.
    public func search<T: QueryElement>(
        index: String,
        type: String = "_doc",
        _ query: QueryContainer<T>
    ) throws -> Future<[AnyHashable: Any]> {
        let url = constructEndpoint(pathComponents: index, type, "_search")
        var headers: HTTPHeaders = [:]

        headers.add(name: .contentType, value: "application/json")

        return try httpClient
            .post(url, headers: headers) { request in
                try request.content.encode(query)
            }
            .deserializeResponse(to: [AnyHashable: Any].self, or: Abort(.badRequest))
    }

    /// Submits a `[AnyHashable: Any]` query to Elasticsearch and attempts to
    /// decode the response into a `Result<T>`, where `T` is a `Decodable` type
    /// you have to supply.
    ///
    /// Feel free to fall-back to this method if your query is too complex for
    /// representing with `QueryContainer`.
    ///
    ///    ```
    ///    let elasticClient = try req.make(ElasticsearchClient.self)
    ///    let query = [
    ///        "query": [
    ///            "match": [
    ///                "country_description": "日本"
    ///            ]
    ///        ]
    ///    ]
    ///    return try elasticClient
    ///        .search(index: "country", query, decodeTo: Country.self, on: req)
    ///        .map(to: [Country].self)
    ///    { result in
    ///        return result.hits.hits.map { $0.source }
    ///    }
    ///    ```
    ///
    /// - Parameters:
    ///     - index: Elasticsearch index to search in.
    ///     - type: Optional Elasticsearch type, defaults to `_doc`.
    ///     - query: An `[AnyHashable: Any]` dictionary to serialize and send.
    ///     - resultType: `Decodable` type into which the response should be decoded.
    ///     - container: Worker to send the request on.
    /// - Returns: Decoded response from Elasticsearch.
    public func search<T: Decodable>(
        index: String,
        type: String = "_doc",
        _ query: [AnyHashable: Any],
        decodeTo resultType: T.Type,
        on container: Container
    ) throws -> Future<Result<T>> {
        let url = constructEndpoint(pathComponents: index, type, "_search")
        let request = try prepareGenericRequest(url: url, body: query, on: container)

        return try httpClient
            .send(request)
            .decodeResponse(to: Result<T>.self, or: Abort(.badRequest))
    }

    /// Submits a `[AnyHashable: Any]` query to Elasticsearch. Instead of
    /// decoding the response, it deserializes the JSON and returns it as
    /// `[AnyHashable: Any]` if possible.
    ///
    /// Feel free to fall-back to this method if your query is too complex for
    /// representing with `QueryContainer`.
    ///
    ///    ```
    ///    let elasticClient = try req.make(ElasticsearchClient.self)
    ///    let query = [
    ///        "query": [
    ///            "fuzzy": [
    ///                "name": [
    ///                    "value": "bolster",
    ///                    "fuzziness": "auto"
    ///                ]
    ///            ]
    ///        ]
    ///    ]
    ///    return try elasticClient
    ///        .search(index: "product", query, on: req)
    ///        .map(to: HTTPStatus.self)
    ///    { response in
    ///        print(response)
    ///        return .ok
    ///    }
    ///    ```
    ///
    /// - Parameters:
    ///     - index: Elasticsearch index to search in.
    ///     - type: Optional Elasticsearch type, defaults to `_doc`.
    ///     - query: An `[AnyHashable: Any]` dictionary to serialize and send.
    ///     - container: Worker to send the request on.
    /// - Returns: `[AnyHashable: Any]` raw response from Elasticsearch.
    public func search(
        index: String,
        type: String = "_doc",
        _ query: [AnyHashable: Any],
        on container: Container
    ) throws -> Future<[AnyHashable: Any]> {
        let url = constructEndpoint(pathComponents: index, type, "_search")
        let request = try prepareGenericRequest(url: url, body: query, on: container)

        return try httpClient
            .send(request)
            .deserializeResponse(to: [AnyHashable: Any].self, or: Abort(.badRequest))
    }

    func constructEndpoint(pathComponents: String...) -> URL {
        return pathComponents.reduce(serverURL) { url, pathComponent -> URL in
            return url.appendingPathComponent(pathComponent)
        }
    }

    func prepareGenericRequest(
        method: HTTPMethod = .POST,
        url: URL,
        body: Any,
        on container: Container
    ) throws -> Request {
        var headers: HTTPHeaders = [:]

        headers.add(name: .contentType, value: "application/json")

        let data = try JSONSerialization.data(withJSONObject: body, options: [])
        let httpRequest = HTTPRequest(method: method, url: url, headers: headers, body: data)

        return Request(http: httpRequest, using: container)
    }

    func mapGeneric(response: Response) throws -> [AnyHashable: Any] {
        guard
            response.http.status == .ok,
            let data = response.http.body.data,
            let result = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any]
        else {
            throw Abort(.badRequest)
        }

        return result
    }
}

internal extension Future where T == Response {
    internal func deserializeResponse<U>(to: U.Type, or error: Error) throws -> Future<U> {
        return map(to: U.self) { response in
            guard
                response.http.status == .ok,
                let data = response.http.body.data,
                let result = try JSONSerialization.jsonObject(with: data, options: []) as? U
            else {
                throw error
            }

            return result
        }
    }

    internal func decodeResponse<U: Decodable>(to: U.Type, or error: Error) throws -> Future<U> {
        return flatMap(to: U.self) { response in
            guard response.http.status == .ok else {
                throw Abort(.badRequest)
            }

            return try response.content.decode(U.self)
        }
    }
}
