import Foundation

// MARK: - Stats Service

final class StatsService {
    static let shared = StatsService()
    
    private init() {}
    
    // MARK: - Match-Level Stats
    
    /// Total tries across all matches
    func totalTries(from matches: [Match]) -> Int {
        matches.reduce(0) { $0 + $1.count(of: .tryScore) }
    }
    
    /// Total tackles across all matches
    func totalTackles(from matches: [Match]) -> Int {
        matches.reduce(0) { $0 + $1.count(of: .tackle) }
    }
    
    /// Total missed tackles across all matches
    func totalMissedTackles(from matches: [Match]) -> Int {
        matches.reduce(0) { $0 + $1.count(of: .missedTackle) }
    }
    
    /// Total breaks across all matches
    func totalBreaks(from matches: [Match]) -> Int {
        matches.reduce(0) { $0 + $1.count(of: .breakThrough) }
    }
    
    /// Total turnovers across all matches
    func totalTurnovers(from matches: [Match]) -> Int {
        matches.reduce(0) { $0 + $1.count(of: .turnover) }
    }
    
    /// Total set piece wins across all matches
    func totalSetPieceWins(from matches: [Match]) -> Int {
        matches.reduce(0) { $0 + $1.count(of: .scrumWin) + $1.count(of: .lineoutWin) }
    }
    
    /// Total conversions across all matches
    func totalConversions(from matches: [Match]) -> Int {
        matches.reduce(0) { $0 + $1.count(of: .conversion) }
    }
    
    // MARK: - Calculated Metrics
    
    /// Tackle success rate (tackles / (tackles + missed tackles))
    func tackleSuccessRate(from matches: [Match]) -> Double {
        let tackles = Double(totalTackles(from: matches))
        let missed = Double(totalMissedTackles(from: matches))
        let total = tackles + missed
        guard total > 0 else { return 0 }
        return tackles / total * 100
    }
    
    /// Conversion success rate
    func conversionRate(from matches: [Match]) -> Double {
        let tries = Double(totalTries(from: matches))
        let conversions = Double(totalConversions(from: matches))
        guard tries > 0 else { return 0 }
        return min(conversions / tries * 100, 100)
    }
    
    /// Breakdown success (turnovers + breaks) / total events
    func breakdownSuccess(from matches: [Match]) -> Double {
        let turnovers = Double(totalTurnovers(from: matches))
        let breaks = Double(totalBreaks(from: matches))
        let totalEvents = Double(matches.reduce(0) { $0 + $1.totalEvents })
        guard totalEvents > 0 else { return 0 }
        return (turnovers + breaks) / totalEvents * 100
    }
    
    /// Territory control estimate (positive events / total events)
    func territoryControl(from matches: [Match]) -> Double {
        let positiveEvents = Double(matches.reduce(0) { total, match in
            total + match.events.filter { $0.type.isPositive }.count
        })
        let totalEvents = Double(matches.reduce(0) { $0 + $1.totalEvents })
        guard totalEvents > 0 else { return 0 }
        return positiveEvents / totalEvents * 100
    }
    
    // MARK: - Radar Chart Data
    
    /// Skill ratings (0-100) for radar chart
    func skillRatings(from matches: [Match]) -> [SkillRating] {
        [
            SkillRating(name: "Attack", value: min(attackRating(from: matches), 100)),
            SkillRating(name: "Defense", value: min(defenseRating(from: matches), 100)),
            SkillRating(name: "Set Piece", value: min(setPieceRating(from: matches), 100)),
            SkillRating(name: "Breakdown", value: min(breakdownSuccess(from: matches), 100)),
            SkillRating(name: "Scoring", value: min(scoringRating(from: matches), 100))
        ]
    }
    
    private func attackRating(from matches: [Match]) -> Double {
        let breaks = Double(totalBreaks(from: matches))
        let tries = Double(totalTries(from: matches))
        let matchCount = max(Double(matches.count), 1)
        return min((breaks * 15 + tries * 20) / matchCount, 100)
    }
    
    private func defenseRating(from matches: [Match]) -> Double {
        tackleSuccessRate(from: matches)
    }
    
    private func setPieceRating(from matches: [Match]) -> Double {
        let wins = Double(totalSetPieceWins(from: matches))
        let matchCount = max(Double(matches.count), 1)
        return min(wins * 20 / matchCount, 100)
    }
    
    private func scoringRating(from matches: [Match]) -> Double {
        let tries = Double(totalTries(from: matches))
        let conversions = Double(totalConversions(from: matches))
        let matchCount = max(Double(matches.count), 1)
        return min((tries * 15 + conversions * 10) / matchCount, 100)
    }
    
    // MARK: - Event Distribution
    
    /// Event distribution for pie chart
    func eventDistribution(from matches: [Match]) -> [EventDistribution] {
        var distribution: [EventDistribution] = []
        
        for type in EventType.allCases {
            let count = matches.reduce(0) { $0 + $1.count(of: type) }
            if count > 0 {
                distribution.append(EventDistribution(type: type, count: count))
            }
        }
        
        return distribution.sorted { $0.count > $1.count }
    }
    
    // MARK: - Per-Match Stats
    
    /// Stats per match for bar chart
    func matchStats(from matches: [Match]) -> [MatchStat] {
        matches.enumerated().map { index, match in
            MatchStat(
                matchIndex: index + 1,
                tries: match.count(of: .tryScore),
                tackles: match.count(of: .tackle),
                momentum: match.momentumIndex,
                date: match.date
            )
        }
    }
}

// MARK: - Supporting Types

struct SkillRating: Identifiable {
    let id = UUID()
    let name: String
    let value: Double
}

struct EventDistribution: Identifiable {
    let id = UUID()
    let type: EventType
    let count: Int
    
    var percentage: Double {
        0 // Calculated in view with total
    }
}

struct MatchStat: Identifiable {
    let id = UUID()
    let matchIndex: Int
    let tries: Int
    let tackles: Int
    let momentum: Double
    let date: Date
    
    var label: String {
        "Match \(matchIndex)"
    }
}
