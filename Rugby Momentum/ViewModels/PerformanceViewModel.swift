import SwiftUI
import Combine

// MARK: - Performance ViewModel

final class PerformanceViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var matches: [Match] = []
    @Published var selectedMetric: PerformanceMetric = .tries
    
    // MARK: - Services
    
    private let statsService = StatsService.shared
    
    // MARK: - Computed Properties
    
    var totalTries: Int {
        statsService.totalTries(from: matches)
    }
    
    var totalTackles: Int {
        statsService.totalTackles(from: matches)
    }
    
    var tackleSuccessRate: Double {
        statsService.tackleSuccessRate(from: matches)
    }
    
    var conversionRate: Double {
        statsService.conversionRate(from: matches)
    }
    
    var territoryControl: Double {
        statsService.territoryControl(from: matches)
    }
    
    var breakdownSuccess: Double {
        statsService.breakdownSuccess(from: matches)
    }
    
    var totalBreaks: Int {
        statsService.totalBreaks(from: matches)
    }
    
    var totalTurnovers: Int {
        statsService.totalTurnovers(from: matches)
    }
    
    var totalConversions: Int {
        statsService.totalConversions(from: matches)
    }
    
    var totalSetPieceWins: Int {
        statsService.totalSetPieceWins(from: matches)
    }
    
    var skillRatings: [SkillRating] {
        statsService.skillRatings(from: matches)
    }
    
    var eventDistribution: [EventDistribution] {
        statsService.eventDistribution(from: matches)
    }
    
    var matchStats: [MatchStat] {
        statsService.matchStats(from: matches)
    }
    
    var totalEvents: Int {
        matches.reduce(0) { $0 + $1.totalEvents }
    }
    
    var averageEventsPerMatch: Double {
        guard !matches.isEmpty else { return 0 }
        return Double(totalEvents) / Double(matches.count)
    }
    
    // MARK: - Stat Cards
    
    var statCards: [StatCard] {
        [
            StatCard(title: "Total Tries", value: "\(totalTries)", icon: "sportscourt.fill"),
            StatCard(title: "Tackles", value: "\(totalTackles)", icon: "figure.rugby"),
            StatCard(title: "Tackle Rate", value: String(format: "%.0f%%", tackleSuccessRate), icon: "shield.fill"),
            StatCard(title: "Territory", value: String(format: "%.0f%%", territoryControl), icon: "map.fill"),
            StatCard(title: "Breakdown", value: String(format: "%.0f%%", breakdownSuccess), icon: "arrow.triangle.2.circlepath"),
            StatCard(title: "Conversions", value: String(format: "%.0f%%", conversionRate), icon: "target")
        ]
    }
    
    // MARK: - Methods
    
    func loadMatches(from allMatches: [Match]) {
        self.matches = allMatches.filter { $0.isCompleted }
    }
}

// MARK: - Supporting Types

struct StatCard: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
}

enum PerformanceMetric: String, CaseIterable {
    case tries = "Tries"
    case tackles = "Tackles"
    case momentum = "Momentum"
}
