import Foundation
import CryptoKit


/// A Store to manage all active challenges.
/// > Note: A challenge is a one-time token to avoid replay attacks of requests.
/// Once issued, the challenge can only be used once by  a subsequent request.
actor ChallengeStore {
    
    // MARK: - Properties
    private var challenges: [String: Date] = [:]
    private let expirationInterval: TimeInterval
    
    // MARK: - Init
    
    /// Creates a new challenge store instance.
    /// - Parameter expirationInterval: the time interval after which challenges expirein seconds, *Default = 300s (5 minutes)*
    init(expirationInterval: TimeInterval = 300) {
        self.expirationInterval = expirationInterval
    }
    
    // MARK: - API
    
    /// Create a new challenge.
    /// - Returns: The created challenge hash.
    func createNewChallenge() -> String {
        let challengeData = Data((0..<32).map { _ in UInt8.random(in: 0...255) })
        let challengeHash = SHA256.hash(data: challengeData).description
        
        challenges[challengeHash] = Date()
        return challengeHash
    }
    
    /// Validate and remove a given challenge if it is present.
    /// - Parameter challenge: The challenge hash which to validate
    /// - Returns: Status if the challenge is present and hence, valid.
    func validateAndRemove(challenge: String) -> Bool {
        if let _ = challenges[challenge] {
            challenges.removeValue(forKey: challenge)
            return true
        }
        return false
    }
    
    /// Invlidates expired challenges.
    /// - Parameter expirationInterval: the time interval after which a challenge expires
    func invalidateExpiredChallenges() {
        let now = Date()
        challenges = challenges.filter { $0.value > now.addingTimeInterval(-expirationInterval) }
    }
}
