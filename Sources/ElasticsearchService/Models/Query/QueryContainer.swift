import Vapor

public struct QueryContainer<T: QueryElement>: Content {
    let query: Query<T>?

    public init(_ query: Query<T>? = nil) {
        self.query = query
    }
}
