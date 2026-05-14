import Foundation

// MARK: - Match Event

struct MatchEvent: Identifiable, Codable {
    let id: UUID
    let type: EventType
    let minute: Int
    let timestamp: Date
    
    init(type: EventType, minute: Int) {
        self.id = UUID()
        self.type = type
        self.minute = minute
        self.timestamp = Date()
    }
    
    /// Formatted minute string (e.g. "23'")
    var minuteLabel: String {
        "\(minute)'"
    }
}
