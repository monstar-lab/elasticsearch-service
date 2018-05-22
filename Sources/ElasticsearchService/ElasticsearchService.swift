import Vapor

public struct ElasticsearchConfig: Service {
    let serverURL: URL

    public init(serverURL: URL) {
        self.serverURL = serverURL
    }
}

public final class ElasticsearchProvider: Provider {
    public init() {}

    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }

    public func register(_ services: inout Services) throws {
        services.register { container -> ElasticsearchClient in
            let httpClient = try container.make(Client.self)
            let config = try container.make(ElasticsearchConfig.self)

            return ElasticsearchClient(httpClient: httpClient, serverURL: config.serverURL)
        }
    }
}
