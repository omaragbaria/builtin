import Foundation

enum Config {
    static let baseURL: URL = {
        let raw = ProcessInfo.processInfo.environment["API_BASE_URL"] ?? "http://localhost:8080/api"
        guard let url = URL(string: raw) else {
            fatalError("Invalid API_BASE_URL: \(raw)")
        }
        return url
    }()
}
