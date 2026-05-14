import SwiftUI

// MARK: - Rugby Event Types

enum EventType: String, Codable, CaseIterable, Identifiable {
    case tryScore = "Try"
    case conversion = "Conversion"
    case tackle = "Tackle"
    case breakThrough = "Break"
    case turnover = "Turnover"
    case scrumWin = "Scrum Win"
    case lineoutWin = "Lineout Win"
    case missedTackle = "Missed Tackle"
    
    var id: String { rawValue }
    
    /// Points awarded for scoring events
    var scorePoints: Int {
        switch self {
        case .tryScore: return 5
        case .conversion: return 2
        default: return 0
        }
    }
    
    /// Momentum weight for the index calculation
    var momentumWeight: Double {
        switch self {
        case .tryScore: return 5.0
        case .breakThrough: return 3.0
        case .turnover: return 2.0
        case .missedTackle: return -2.0
        case .tackle: return 1.0
        case .scrumWin: return 1.5
        case .lineoutWin: return 1.5
        case .conversion: return 2.0
        }
    }
    
    /// SF Symbol icon name
    var icon: String {
        switch self {
        case .tryScore: return "sportscourt.fill"
        case .conversion: return "target"
        case .tackle: return "figure.rugby"
        case .breakThrough: return "bolt.fill"
        case .turnover: return "arrow.triangle.2.circlepath"
        case .scrumWin: return "person.3.fill"
        case .lineoutWin: return "arrow.up.circle.fill"
        case .missedTackle: return "xmark.circle.fill"
        }
    }
    
    /// Color tint for the event
    var color: Color {
        switch self {
        case .tryScore: return .primaryRed
        case .conversion: return .accentCrimson
        case .tackle: return .deepRed
        case .breakThrough: return .orange
        case .turnover: return .green
        case .scrumWin: return .primaryRed
        case .lineoutWin: return .blue
        case .missedTackle: return .gray
        }
    }
    
    /// Whether this is a positive event for momentum
    var isPositive: Bool {
        self != .missedTackle
    }
    
    /// Category for grouping in stats
    var category: EventCategory {
        switch self {
        case .tryScore, .conversion: return .scoring
        case .tackle, .missedTackle: return .defense
        case .breakThrough, .turnover: return .attack
        case .scrumWin, .lineoutWin: return .setpiece
        }
    }
}

// MARK: - Event Category

enum EventCategory: String, CaseIterable {
    case scoring = "Scoring"
    case defense = "Defense"
    case attack = "Attack"
    case setpiece = "Set Piece"
}
