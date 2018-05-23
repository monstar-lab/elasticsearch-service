import Vapor

public struct Exists: Content {
    let field: String

    public init(field: String) {
        self.field = field
    }
}
