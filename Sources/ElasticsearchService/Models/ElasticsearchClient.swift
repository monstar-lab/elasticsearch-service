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
        var headers: HTTPHeaders = [:]

        headers.add(name: .contentType, value: "application/json")

        let data = try JSONSerialization.data(withJSONObject: query, options: [])
        let httpRequest = HTTPRequest(method: .POST, url: url, headers: headers, body: data)
        let request = Request(http: httpRequest, using: container)

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

    func constructEndpoint(pathComponents: String...) -> URL {
        return pathComponents.reduce(serverURL) { url, pathComponent -> URL in
            return url.appendingPathComponent(pathComponent)
        }
    }
}
