import Foundation

enum APIError: LocalizedError {
    case unauthorized
    case notFound
    case noDriversAvailable
    case serverError(Int, String?)
    case decodingError(Error)
    case networkError(Error)
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Session expired. Please log in again."
        case .notFound:
            return "The requested resource was not found."
        case .noDriversAvailable:
            return "No drivers are currently available for immediate delivery. Please choose another shipping method."
        case .serverError(let code, let message):
            return message ?? "Server error (\(code))."
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .networkError(let error):
            return error.localizedDescription
        case .invalidURL:
            return "Invalid request URL."
        }
    }
}
