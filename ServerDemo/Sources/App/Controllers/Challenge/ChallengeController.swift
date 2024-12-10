import Vapor


/// Controller to retrieve and validate challenges.
final class ChallengeController: RouteCollection, @unchecked Sendable {
    
    // MARK: - Properties
    
    private let challengeStore: ChallengeStore
        
    // MARK: - Init
    
    /// Creates a new controller instance.
    /// - Parameters:
    ///   - app: the server application instance
    ///   - challengeStore: the Store to manage all active challenges
    init(
        app: Application,
        challengeStore: ChallengeStore
    ) {
        self.challengeStore = challengeStore
        
        // Background task to clean up expired challenges
        app.eventLoopGroup.next().scheduleRepeatedTask(initialDelay: .zero, delay: .seconds(60)) { [challengeStore] _ in
            Task {
                await challengeStore.invalidateExpiredChallenges()
            }
        }
    }
    
    func boot(routes: any RoutesBuilder) throws {
        let challengeRoutes = routes.grouped("challenge")
        challengeRoutes.get(use: generateChallenge)
        challengeRoutes.post("validate", use: validateChallenge)
    }
    
    // MARK: - API
    
    // MARK: - Get Challenge
    
    /// Generate a new challenge
    /// - Parameter req: the request to get a new challenge
    /// - Returns: the response which contains the challenge
    @Sendable
    private func generateChallenge(req: Request) async throws -> Response {
        // Store the challenge
        let challenge = await challengeStore.createNewChallenge()

        // Return the challenge hash
        return Response(
            status: .ok,
            body: Response.Body(string: challenge)
        )
    }
        
    // MARK: - Validate challenge

    
    /// Validates a challenge
    /// - Parameter req: the incoming request which to validate it's challenge
    /// - Returns: HTTP status whether the challange is valid or not
    @Sendable
    func validateChallenge(req: Request) async throws -> HTTPStatus {        
        guard let challenge = req.headers[.nonce].first else {
            throw Abort(.badRequest, reason: "Missing Nonce header")
        }
        
        let isValid = await challengeStore.validateAndRemove(challenge: challenge)
        return isValid ? .ok : .unauthorized
    }
}

// MARK: - Request Header fields

fileprivate extension String {
    
    /// The challenge / nonce header field.
    static var nonce: String { "Nonce" }
    
}
