import Foundation

// MARK: - Momentum Service

final class MomentumService {
    static let shared = MomentumService()
    
    private init() {}
    
    // MARK: - Momentum Index Calculation
    
    /// Calculate momentum index for a match
    /// Formula: (tries×5 + breaks×3 + turnovers×2 − missedTackles×2) ÷ totalEvents
    func calculateMomentumIndex(for match: Match) -> Double {
        guard match.totalEvents > 0 else { return 0 }
        
        let tries = Double(match.count(of: .tryScore)) * 5.0
        let breaks = Double(match.count(of: .breakThrough)) * 3.0
        let turnovers = Double(match.count(of: .turnover)) * 2.0
        let missed = Double(match.count(of: .missedTackle)) * 2.0
        let conversions = Double(match.count(of: .conversion)) * 2.0
        let tackles = Double(match.count(of: .tackle)) * 1.0
        let scrumWins = Double(match.count(of: .scrumWin)) * 1.5
        let lineoutWins = Double(match.count(of: .lineoutWin)) * 1.5
        
        let numerator = tries + breaks + turnovers + conversions + tackles + scrumWins + lineoutWins - missed
        return numerator / Double(match.totalEvents)
    }
    
    /// Calculate momentum for a specific time window
    func calculateWindowMomentum(events: [MatchEvent], from: Int, to: Int) -> Double {
        let windowEvents = events.filter { $0.minute >= from && $0.minute < to }
        guard !windowEvents.isEmpty else { return 0 }
        
        let weightedSum = windowEvents.reduce(0.0) { $0 + $1.type.momentumWeight }
        return weightedSum / Double(windowEvents.count)
    }
    
    // MARK: - Momentum Timeline
    
    /// Generate momentum timeline points for a match
    func generateTimeline(for match: Match, intervalMinutes: Int = 5) -> [MomentumPoint] {
        guard !match.events.isEmpty else { return [] }
        
        let maxMinute = max(match.events.map { $0.minute }.max() ?? 0, intervalMinutes)
        var points: [MomentumPoint] = []
        
        for minute in stride(from: 0, through: maxMinute, by: intervalMinutes) {
            let momentum = calculateWindowMomentum(
                events: match.events,
                from: max(0, minute - intervalMinutes),
                to: minute + intervalMinutes
            )
            points.append(MomentumPoint(minute: minute, value: momentum))
        }
        
        return points
    }
    
    // MARK: - Peak Momentum Analysis
    
    /// Find peak momentum moments in a match
    func findPeakMoments(for match: Match) -> [PeakMoment] {
        let timeline = generateTimeline(for: match, intervalMinutes: 5)
        guard !timeline.isEmpty else { return [] }
        
        var peaks: [PeakMoment] = []
        
        for (index, point) in timeline.enumerated() {
            let prevValue = index > 0 ? timeline[index - 1].value : 0
            let nextValue = index < timeline.count - 1 ? timeline[index + 1].value : 0
            
            if point.value > prevValue && point.value >= nextValue && point.value > 1.0 {
                peaks.append(PeakMoment(
                    minute: point.minute,
                    momentum: point.value,
                    isDominant: point.value > 3.0
                ))
            }
        }
        
        return peaks.sorted { $0.momentum > $1.momentum }
    }
    
    // MARK: - Momentum Level
    
    /// Get momentum level description
    func momentumLevel(for index: Double) -> MomentumLevel {
        switch index {
        case ..<0:
            return .declining
        case 0..<1.5:
            return .building
        case 1.5..<3.0:
            return .rising
        case 3.0..<4.0:
            return .dominant
        default:
            return .unstoppable
        }
    }
    
    /// Average momentum across all matches
    func averageMomentum(from matches: [Match]) -> Double {
        guard !matches.isEmpty else { return 0 }
        let total = matches.reduce(0.0) { $0 + calculateMomentumIndex(for: $1) }
        return total / Double(matches.count)
    }
    
    /// Best momentum match
    func bestMatch(from matches: [Match]) -> Match? {
        matches.max(by: { calculateMomentumIndex(for: $0) < calculateMomentumIndex(for: $1) })
    }
}

// MARK: - Supporting Types

struct PeakMoment: Identifiable {
    let id = UUID()
    let minute: Int
    let momentum: Double
    let isDominant: Bool
    
    var label: String {
        "\(minute)' - \(isDominant ? "Dominant" : "Peak")"
    }
}

enum MomentumLevel: String {
    case declining = "Declining"
    case building = "Building"
    case rising = "Rising"
    case dominant = "Dominant"
    case unstoppable = "Unstoppable"
    
    var emoji: String {
        switch self {
        case .declining: return "📉"
        case .building: return "📈"
        case .rising: return "🔥"
        case .dominant: return "💪"
        case .unstoppable: return "⚡"
        }
    }
    
    var intensity: Double {
        switch self {
        case .declining: return 0.2
        case .building: return 0.4
        case .rising: return 0.6
        case .dominant: return 0.8
        case .unstoppable: return 1.0
        }
    }
}
