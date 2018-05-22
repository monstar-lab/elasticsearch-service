import Vapor

public final class ElasticsearchClient: Service {
    let httpClient: Client
    let serverURL: URL

    public init(httpClient: Client, serverURL: URL) {
        self.httpClient = httpClient
        self.serverURL = serverURL
    }

    public func search(index: String, type: String = "_doc", _ query: [AnyHashable: Any], on container: Container) throws -> Future<[AnyHashable: Any]> {
        let url = constructEndpoint(pathComponents: index, type, "_search")
        let request = try prepareGenericRequest(url: url, body: query, on: container)

        return httpClient.send(request).map(to: [AnyHashable: Any].self) { response in
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

    public func search<T: Decodable>(index: String, type: String = "_doc", _ query: [AnyHashable: Any], decodeTo resultType: T.Type, on container: Container) throws -> Future<Result<T>> {
        let url = constructEndpoint(pathComponents: index, type, "_search")
        let request = try prepareGenericRequest(url: url, body: query, on: container)

        return httpClient.send(request).flatMap(to: Result<T>.self) { response in
            guard response.http.status == .ok else {
                throw Abort(.badRequest)
            }

            return try response.content.decode(Result<T>.self)
        }
    }

    func constructEndpoint(pathComponents: String...) -> URL {
        return pathComponents.reduce(serverURL) { url, pathComponent -> URL in
            return url.appendingPathComponent(pathComponent)
        }
    }

    func prepareGenericRequest(method: HTTPMethod = .POST, url: URL, body: Any, on container: Container) throws -> Request {
        var headers: HTTPHeaders = [:]

        headers.add(name: .contentType, value: "application/json")

        let data = try JSONSerialization.data(withJSONObject: body, options: [])
        let httpRequest = HTTPRequest(method: method, url: url, headers: headers, body: data)

        return Request(http: httpRequest, using: container)
    }
}
