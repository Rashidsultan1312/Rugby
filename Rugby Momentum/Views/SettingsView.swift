import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @ObservedObject var matchVM: MatchViewModel
    @ObservedObject var achievementVM: AchievementViewModel
    
    var body: some View {
        ZStack {
            RugbyBackgroundView()
            
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    preferencesSection
                    teamDefaultsSection
                    dataSection
                    aboutSection
                    Spacer(minLength: 20)
                }
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            if settingsVM.showConfirmReset {
                CustomConfirmPopup(
                    title: "Reset All Data?",
                    message: "This will delete all matches, stats, and achievements. This action cannot be undone.",
                    confirmTitle: "Reset",
                    confirmRole: .destructive,
                    onConfirm: {
                        settingsVM.showConfirmReset = false
                        settingsVM.resetAllData(matchVM: matchVM, achievementVM: achievementVM)
                        HapticService.shared.warning()
                    },
                    onCancel: { settingsVM.showConfirmReset = false }
                )
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("SETTINGS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.pureWhite.opacity(0.6))
                .tracking(3)
        }
        .padding(.top, 16)
    }
    
    // MARK: - Preferences
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("PREFERENCES")
            
            VStack(spacing: 0) {
                // Haptic feedback toggle
                settingsRow {
                    CustomToggle(
                        title: "Haptic Feedback",
                        isOn: $settingsVM.hapticEnabled,
                        icon: "hand.tap.fill"
                    )
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.pureWhite)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Team Defaults
    
    private var teamDefaultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("TEAM DEFAULTS")
            
            VStack(spacing: 0) {
                settingsRow {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.primaryRed)
                            .frame(width: 30)
                        
                        Text("Home Team")
                            .font(.system(size: 15, weight: .medium))
                        
                        Spacer()
                        
                        CustomTextField(
                            placeholder: "Home",
                            text: $settingsVM.defaultHomeName,
                            alignment: .trailing
                        )
                        .frame(width: 140)
                    }
                }
                
                RugbySeparator()
                
                settingsRow {
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.deepRed)
                            .frame(width: 30)
                        
                        Text("Away Team")
                            .font(.system(size: 15, weight: .medium))
                        
                        Spacer()
                        
                        CustomTextField(
                            placeholder: "Away",
                            text: $settingsVM.defaultAwayName,
                            alignment: .trailing
                        )
                        .frame(width: 140)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.pureWhite)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Data Section
    
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("DATA")
            
            VStack(spacing: 0) {
                settingsRow {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.primaryRed)
                            .frame(width: 30)
                        
                        Text("Matches Recorded")
                            .font(.system(size: 15, weight: .medium))
                        
                        Spacer()
                        
                        Text("\(matchVM.allMatches.count)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                
                RugbySeparator()
                
                settingsRow {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.accentCrimson)
                            .frame(width: 30)
                        
                        Text("Achievements Unlocked")
                            .font(.system(size: 15, weight: .medium))
                        
                        Spacer()
                        
                        Text(achievementVM.progressLabel)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                }
                
                RugbySeparator()
                
                // Reset button
                Button(action: { settingsVM.showConfirmReset = true }) {
                    settingsRow {
                        HStack {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                                .frame(width: 30)
                            
                            Text("Reset All Data")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.red)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.pureWhite)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("ABOUT")
            
            VStack(spacing: 0) {
                settingsRow {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.primaryRed)
                            .frame(width: 30)
                        
                        Text("Version")
                            .font(.system(size: 15, weight: .medium))
                        
                        Spacer()
                        
                        Text("\(settingsVM.appVersion) (\(settingsVM.buildNumber))")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
                
                RugbySeparator()
                
                settingsRow {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.primaryRed)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Privacy")
                                .font(.system(size: 15, weight: .medium))
                            Text("All data stored locally. No internet required.")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.pureWhite)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            )
            
            // App branding
            VStack(spacing: 8) {
                Text("Rugby Momentum")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.pureWhite)
                
                Text("Track Every Impact")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.pureWhite.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helpers
    
    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.pureWhite.opacity(0.6))
            .tracking(2)
    }
    
    @ViewBuilder
    private func settingsRow<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
    }
}
