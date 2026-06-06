import Foundation

actor APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private var sessionToken: String?

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)

            // Try ISO8601 with fractional seconds first, then without
            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso.date(from: raw) { return date }

            iso.formatOptions = [.withInternetDateTime]
            if let date = iso.date(from: raw) { return date }

            // LocalDateTime from Spring (no timezone)
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "en_US_POSIX")
            fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = fmt.date(from: raw) { return date }

            fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            if let date = fmt.date(from: raw) { return date }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unrecognised date: \(raw)")
        }
        return d
    }()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func setToken(_ token: String?) {
        self.sessionToken = token
    }

    // MARK: - Typed response

    func request<T: Decodable>(
        _ endpoint: Endpoint,
        method: HTTPMethod = .get,
        body: (any Encodable)? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        let data = try await execute(endpoint, method: method, body: body, queryItems: queryItems)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Void response

    func requestVoid(
        _ endpoint: Endpoint,
        method: HTTPMethod = .post,
        body: (any Encodable)? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws {
        _ = try await execute(endpoint, method: method, body: body, queryItems: queryItems)
    }

    // MARK: - Raw data (for photo proxy)

    func requestData(
        _ endpoint: Endpoint,
        method: HTTPMethod = .get
    ) async throws -> (Data, String?) {
        let (data, response) = try await performRequest(endpoint, method: method, body: nil, queryItems: nil)
        let contentType = (response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Content-Type")
        return (data, contentType)
    }

    // MARK: - Core execute

    private func execute(
        _ endpoint: Endpoint,
        method: HTTPMethod,
        body: (any Encodable)?,
        queryItems: [URLQueryItem]?
    ) async throws -> Data {
        let (data, response) = try await performRequest(endpoint, method: method, body: body, queryItems: queryItems)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }

        switch http.statusCode {
        case 200...299:
            return data
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        default:
            let message = String(data: data, encoding: .utf8)
            // Spring Boot may return "No drivers available" in 409/400 body
            if let msg = message, msg.lowercased().contains("driver") || msg.lowercased().contains("immediate") {
                throw APIError.noDriversAvailable
            }
            throw APIError.serverError(http.statusCode, message)
        }
    }

    private func performRequest(
        _ endpoint: Endpoint,
        method: HTTPMethod,
        body: (any Encodable)?,
        queryItems: [URLQueryItem]?
    ) async throws -> (Data, URLResponse) {
        var components = URLComponents(url: endpoint.url, resolvingAgainstBaseURL: false)
        if let queryItems { components?.queryItems = queryItems }
        guard let url = components?.url else { throw APIError.invalidURL }

        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = sessionToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            req.httpBody = try encoder.encode(body)
        }

        do {
            return try await session.data(for: req)
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: -

enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
}
