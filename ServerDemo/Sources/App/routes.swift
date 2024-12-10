import Vapor

/// Configures routes and controllers for all API endpoints.
/// - Parameter app: the server application instance
/// - Throws: A potential error caused by some route setup.
func routes(_ app: Application) throws {
    let challengeStore = ChallengeStore()
    
    let challengeController = ChallengeController(
        app: app,
        challengeStore: challengeStore
    )
    
    // Register challenge routes
    try app.register(collection: challengeController)
}
