import Vapor

/// Configures the application.
/// - Parameter app: the server application instance
/// - Throws: A potential error caused by some configuration setup.
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    // register routes
    
    app.http.server.configuration.port = 8088
    
    try routes(app)
}
