import Vapor

public struct QueryContainer: Content {
    let query: Query?

    public init(_ query: Query? = nil) {
        self.query = query
    }
}
