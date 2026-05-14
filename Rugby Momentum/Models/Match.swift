import Foundation

// MARK: - Match Model

struct Match: Identifiable, Codable {
    let id: UUID
    let date: Date
    var events: [MatchEvent]
    var homeScore: Int
    var awayScore: Int
    var duration: Int // in seconds
    var isCompleted: Bool
    var homeName: String
    var awayName: String
    
    init(homeName: String = "Home", awayName: String = "Away") {
        self.id = UUID()
        self.date = Date()
        self.events = []
        self.homeScore = 0
        self.awayScore = 0
        self.duration = 0
        self.isCompleted = false
        self.homeName = homeName
        self.awayName = awayName
    }
    
    /// Current match minute based on duration
    var currentMinute: Int {
        duration / 60
    }
    
    /// Total event count
    var totalEvents: Int {
        events.count
    }
    
    /// Count of specific event type
    func count(of type: EventType) -> Int {
        events.filter { $0.type == type }.count
    }
    
    /// Events grouped by minute for timeline
    var eventsByMinute: [Int: [MatchEvent]] {
        Dictionary(grouping: events, by: { $0.minute })
    }
    
    /// Formatted duration string
    var durationLabel: String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Formatted date string
    var dateLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Momentum index for the match
    var momentumIndex: Double {
        guard totalEvents > 0 else { return 0 }
        let weightedSum = events.reduce(0.0) { $0 + $1.type.momentumWeight }
        return weightedSum / Double(totalEvents)
    }
    
    /// Momentum values over time (per 5-minute intervals)
    var momentumTimeline: [MomentumPoint] {
        guard !events.isEmpty else { return [] }
        let maxMinute = events.map { $0.minute }.max() ?? 0
        let intervalSize = 5
        var points: [MomentumPoint] = []
        
        var runningMomentum: Double = 0
        var eventCount: Int = 0
        
        for interval in stride(from: 0, through: max(maxMinute, intervalSize), by: intervalSize) {
            let intervalEvents = events.filter { $0.minute >= interval && $0.minute < interval + intervalSize }
            eventCount += intervalEvents.count
            let intervalWeight = intervalEvents.reduce(0.0) { $0 + $1.type.momentumWeight }
            runningMomentum += intervalWeight
            
            let value = eventCount > 0 ? runningMomentum / Double(eventCount) : 0
            points.append(MomentumPoint(minute: interval, value: value))
        }
        
        return points
    }
}

// MARK: - Momentum Point

struct MomentumPoint: Identifiable {
    let id = UUID()
    let minute: Int
    let value: Double
    
    var minuteLabel: String {
        "\(minute)'"
    }
}
