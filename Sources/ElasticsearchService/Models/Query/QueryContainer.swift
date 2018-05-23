import Vapor

public struct QueryContainer: Content {
    let query: Query?

    init(_ query: Query? = nil) {
        self.query = query
    }
}
