import Vapor
import JSON

public final class ElasticsearchClient: Service {
    let httpClient: Client
    let serverURL: URL

    public init(httpClient: Client, serverURL: URL) {
        self.httpClient = httpClient
        self.serverURL = serverURL
    }

    public func search(index: String, type: String = "_doc", _ query: JSON, on worker: Worker) throws -> Future<JSON> {
        var headers: HTTPHeaders = [:]
        let url = constructEndpoint(pathComponents: index, type, "_search")

        headers.add(name: .contentType, value: "application/json")

        let request = httpClient.post(url, headers: headers) { req in
            try req.content.encode(json: query)
        }

        return request.flatMap(to: JSON.self) { response in
            if response.http.status != .ok {
                throw Abort(.badRequest)
            }

            do {
                return try response.content.decode(JSON.self)
            } catch {
                throw Abort(.internalServerError)
            }
        }
    }

    func constructEndpoint(pathComponents: String...) -> URL {
        return pathComponents.reduce(serverURL) { url, pathComponent -> URL in
            return url.appendingPathComponent(pathComponent)
        }
    }
}

