import Vapor

/// Configures routes and controllers for all API endpoints.
/// - Parameter app: the server application instance
/// - Throws: A potential error caused by some route setup.
func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
}
