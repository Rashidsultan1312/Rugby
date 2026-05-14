import SwiftUI
import Combine

// MARK: - Momentum ViewModel

final class MomentumViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var matches: [Match] = []
    @Published var selectedMatch: Match?
    @Published var timeline: [MomentumPoint] = []
    @Published var peakMoments: [PeakMoment] = []
    @Published var momentumLevel: MomentumLevel = .building
    @Published var showSparkEffect: Bool = false
    @Published var wavePhase: Double = 0
    
    // MARK: - Services
    
    private let momentumService = MomentumService.shared
    private var waveTimer: AnyCancellable?
    
    // MARK: - Computed Properties
    
    var currentMomentumIndex: Double {
        guard let match = selectedMatch else { return 0 }
        return momentumService.calculateMomentumIndex(for: match)
    }
    
    var averageMomentum: Double {
        momentumService.averageMomentum(from: matches)
    }
    
    var bestMatch: Match? {
        momentumService.bestMatch(from: matches)
    }
    
    var bestMomentumIndex: Double {
        guard let best = bestMatch else { return 0 }
        return momentumService.calculateMomentumIndex(for: best)
    }
    
    var formattedMomentumIndex: String {
        String(format: "%.1f", currentMomentumIndex)
    }
    
    var formattedAverageMomentum: String {
        String(format: "%.1f", averageMomentum)
    }
    
    // MARK: - Init
    
    init() {
        startWaveAnimation()
    }
    
    deinit {
        waveTimer?.cancel()
    }
    
    // MARK: - Methods
    
    func loadMatches(from allMatches: [Match]) {
        self.matches = allMatches.filter { $0.isCompleted }
        if selectedMatch == nil, let latest = self.matches.last {
            selectMatch(latest)
        }
    }
    
    func selectMatch(_ match: Match) {
        selectedMatch = match
        timeline = momentumService.generateTimeline(for: match)
        peakMoments = momentumService.findPeakMoments(for: match)
        momentumLevel = momentumService.momentumLevel(for: currentMomentumIndex)
        showSparkEffect = currentMomentumIndex >= 3.0
    }
    
    /// Get momentum index for a specific match
    func momentumIndex(for match: Match) -> Double {
        momentumService.calculateMomentumIndex(for: match)
    }
    
    /// Start the wave animation timer
    private func startWaveAnimation() {
        waveTimer = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.wavePhase += 0.05
            }
    }
}
