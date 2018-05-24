import Vapor

public final class ElasticsearchClient: Service {
    let httpClient: Client
    let serverURL: URL

    public init(httpClient: Client, serverURL: URL) {
        self.httpClient = httpClient
        self.serverURL = serverURL
    }

    public func search<T: QueryElement>(
        index: String,
        type: String = "_doc",
        _ query: QueryContainer<T>,
        on container: Container
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

    public func search<T: QueryElement, U: Decodable>(
        index: String,
        type: String = "_doc",
        _ query: QueryContainer<T>,
        decodeTo resultType: U.Type,
        on container: Container
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
