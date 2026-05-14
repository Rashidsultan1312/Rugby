import SwiftUI
import Combine

// MARK: - Achievement ViewModel

final class AchievementViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var achievements: [Achievement] = []
    @Published var newlyUnlocked: [AchievementType] = []
    @Published var showUnlockAnimation: Bool = false
    
    // MARK: - Services
    
    private let achievementService = AchievementService.shared
    
    // MARK: - Computed Properties
    
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var totalCount: Int {
        achievements.count
    }
    
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(unlockedCount) / Double(totalCount)
    }
    
    var progressLabel: String {
        "\(unlockedCount)/\(totalCount)"
    }
    
    var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }
    }
    
    var lockedAchievements: [Achievement] {
        achievements.filter { !$0.isUnlocked }
    }
    
    // MARK: - Init
    
    init() {
        loadAchievements()
    }
    
    // MARK: - Methods
    
    /// Load achievements from service
    func loadAchievements() {
        achievements = achievementService.loadAchievements()
    }
    
    /// Check achievements against current match data
    func checkAchievements(matches: [Match]) {
        let unlocked = achievementService.checkAchievements(matches: matches)
        if !unlocked.isEmpty {
            newlyUnlocked = unlocked
            showUnlockAnimation = true
            loadAchievements()
            HapticService.shared.success()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                self?.showUnlockAnimation = false
                self?.newlyUnlocked.removeAll()
            }
        }
    }
    
    /// Reset all achievements
    func resetAchievements() {
        achievementService.resetAchievements()
        loadAchievements()
    }
}
