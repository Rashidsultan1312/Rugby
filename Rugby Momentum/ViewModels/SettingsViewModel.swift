import SwiftUI
import Combine

// MARK: - Settings ViewModel

final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var hapticEnabled: Bool {
        didSet { UserDefaults.standard.set(hapticEnabled, forKey: "haptic_enabled") }
    }
    
    @Published var defaultHomeName: String {
        didSet { UserDefaults.standard.set(defaultHomeName, forKey: "default_home_name") }
    }
    
    @Published var defaultAwayName: String {
        didSet { UserDefaults.standard.set(defaultAwayName, forKey: "default_away_name") }
    }
    
    @Published var showConfirmReset: Bool = false
    @Published var showConfirmResetAchievements: Bool = false
    
    // MARK: - App Info
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    // MARK: - Init
    
    init() {
        self.hapticEnabled = UserDefaults.standard.object(forKey: "haptic_enabled") as? Bool ?? true
        self.defaultHomeName = UserDefaults.standard.string(forKey: "default_home_name") ?? "Home"
        self.defaultAwayName = UserDefaults.standard.string(forKey: "default_away_name") ?? "Away"
    }
    
    // MARK: - Methods
    
    /// Reset all match data
    func resetAllData(matchVM: MatchViewModel, achievementVM: AchievementViewModel) {
        matchVM.deleteAllMatches()
        achievementVM.resetAchievements()
    }
    
    /// Check if onboarding was shown
    var hasSeenOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "has_seen_onboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "has_seen_onboarding") }
    }
}
