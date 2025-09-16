import Foundation

/// Application-wide constants
enum AppConstants {
    /// API Configuration
    enum API {
        static let baseURL = "http://numbersapi.com"
        static let timeoutInterval: TimeInterval = 15
        static let resourceTimeoutInterval: TimeInterval = 20
    }
    
    /// Storage Configuration
    enum Storage {
        static let maxStoredFacts = 100
        static let historyLimit = 50
    }
    
    /// UI Configuration
    enum UI {
        static let animationDuration: Double = 0.3
        static let cornerRadius: CGFloat = 8
        static let shadowRadius: CGFloat = 1
    }
}
