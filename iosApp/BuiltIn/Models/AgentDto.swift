import Foundation

struct AgentRequest: Encodable {
    let message: String
}

struct AgentResponse: Decodable {
    let projectSummary: String?
    let materials: [MaterialLine]
}
