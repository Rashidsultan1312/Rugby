import SwiftUI
import Combine

// MARK: - Match ViewModel

final class MatchViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentMatch: Match?
    @Published var allMatches: [Match] = []
    @Published var isMatchActive: Bool = false
    @Published var elapsedSeconds: Int = 0
    @Published var showFlashEffect: Bool = false
    @Published var lastEventType: EventType?
    @Published var homeName: String = "Home"
    @Published var awayName: String = "Away"
    
    // MARK: - Private Properties
    
    private var timer: AnyCancellable?
    private let matchesKey = "rugby_matches"
    private let haptic = HapticService.shared
    
    // MARK: - Computed Properties
    
    var currentMinute: Int {
        elapsedSeconds / 60
    }
    
    var timerLabel: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var homeScore: Int {
        currentMatch?.homeScore ?? 0
    }
    
    var awayScore: Int {
        currentMatch?.awayScore ?? 0
    }
    
    var events: [MatchEvent] {
        currentMatch?.events ?? []
    }
    
    var recentEvents: [MatchEvent] {
        Array(events.suffix(10).reversed())
    }
    
    var completedMatches: [Match] {
        allMatches.filter { $0.isCompleted }
    }
    
    // MARK: - Init
    
    init() {
        loadMatches()
    }
    
    // MARK: - Match Control
    
    /// Start a new match
    func startMatch() {
        var match = Match(homeName: homeName, awayName: awayName)
        match.duration = 0
        currentMatch = match
        isMatchActive = true
        elapsedSeconds = 0
        startTimer()
        haptic.mediumImpact()
    }
    
    /// End the current match
    func endMatch() {
        stopTimer()
        currentMatch?.isCompleted = true
        currentMatch?.duration = elapsedSeconds
        isMatchActive = false
        
        if let match = currentMatch {
            if let index = allMatches.firstIndex(where: { $0.id == match.id }) {
                allMatches[index] = match
            } else {
                allMatches.append(match)
            }
            saveMatches()
        }
        
        haptic.success()
    }
    
    /// Reset current match (discard without saving)
    func discardMatch() {
        stopTimer()
        currentMatch = nil
        isMatchActive = false
        elapsedSeconds = 0
    }
    
    // MARK: - Event Logging
    
    /// Add an event to the current match
    func addEvent(_ type: EventType) {
        guard var match = currentMatch else { return }
        
        let event = MatchEvent(type: type, minute: currentMinute)
        match.events.append(event)
        
        // Update score for scoring events
        match.homeScore += type.scorePoints
        
        currentMatch = match
        lastEventType = type
        
        showFlashEffect = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.showFlashEffect = false
        }
        
        haptic.eventHaptic(for: type)
    }
    
    /// Update opponent score manually
    func updateAwayScore(_ score: Int) {
        currentMatch?.awayScore = max(0, score)
    }
    
    func incrementAwayScore() {
        currentMatch?.awayScore = (currentMatch?.awayScore ?? 0) + 1
    }
    
    func decrementAwayScore() {
        let current = currentMatch?.awayScore ?? 0
        currentMatch?.awayScore = max(0, current - 1)
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.elapsedSeconds += 1
                self?.currentMatch?.duration = self?.elapsedSeconds ?? 0
            }
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    // MARK: - Persistence
    
    func loadMatches() {
        guard let data = UserDefaults.standard.data(forKey: matchesKey),
              let matches = try? JSONDecoder().decode([Match].self, from: data) else {
            return
        }
        allMatches = matches
    }
    
    func saveMatches() {
        if let data = try? JSONEncoder().encode(allMatches) {
            UserDefaults.standard.set(data, forKey: matchesKey)
        }
    }
    
    /// Delete a match
    func deleteMatch(at indexSet: IndexSet) {
        allMatches.remove(atOffsets: indexSet)
        saveMatches()
    }
    
    /// Delete all matches
    func deleteAllMatches() {
        allMatches.removeAll()
        currentMatch = nil
        isMatchActive = false
        elapsedSeconds = 0
        stopTimer()
        saveMatches()
    }
}
