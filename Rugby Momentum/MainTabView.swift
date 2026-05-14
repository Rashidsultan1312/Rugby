import SwiftUI

// MARK: - Main Tab View

struct MainTabView: View {
    @StateObject private var matchVM = MatchViewModel()
    @StateObject private var performanceVM = PerformanceViewModel()
    @StateObject private var momentumVM = MomentumViewModel()
    @StateObject private var achievementVM = AchievementViewModel()
    @StateObject private var settingsVM = SettingsViewModel()
    @StateObject private var resolver = LaunchResolver()
    
    @State private var selectedTab: TabItem = .matchTracker
    @State private var showLoading = true
    @State private var showOnboarding = false
    @State private var remoteContentPath: String?
    
    var body: some View {
        ZStack {
            if showLoading {
                LoadingView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showLoading = false
                        if let path = resolver.destination {
                            remoteContentPath = path
                        } else if !settingsVM.hasSeenOnboarding {
                            showOnboarding = true
                        }
                    }
                }
                .transition(.opacity)
                .onAppear { resolver.check() }
            } else if let path = remoteContentPath {
                RemoteContentView(url: path)
                    .transition(.opacity)
            } else if showOnboarding {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        settingsVM.hasSeenOnboarding = true
                        showOnboarding = false
                    }
                }
                .transition(.opacity)
            } else {
                mainTabView
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showLoading)
        .animation(.easeInOut(duration: 0.3), value: showOnboarding)
        .onChange(of: selectedTab) { _ in
            refreshData()
        }
    }
    
    // MARK: - Main Tab Content
    
    private var mainTabView: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .matchTracker:
                    MatchTrackerView(matchVM: matchVM, achievementVM: achievementVM)
                case .performance:
                    PerformanceView(performanceVM: performanceVM)
                case .momentum:
                    MomentumView(momentumVM: momentumVM)
                case .achievements:
                    AchievementsView(achievementVM: achievementVM)
                case .settings:
                    SettingsView(settingsVM: settingsVM, matchVM: matchVM, achievementVM: achievementVM)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            customTabBar
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            refreshData()
        }
    }
    
    // MARK: - Custom Tab Bar
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                RugbyTabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab
                ) {
                    selectedTab = tab
                    HapticService.shared.selectionChanged()
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(
            ZStack {
                LinearGradient(
                    colors: [.deepRed, .primaryRed, .deepRed],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack {
                    Rectangle()
                        .fill(Color.pureWhite.opacity(0.9))
                        .frame(height: 2)
                    Spacer()
                }
                
                VStack {
                    LinearGradient(
                        colors: [.black.opacity(0.15), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 4)
                    Spacer()
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.pureWhite.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.25), radius: 16, y: -4)
        .padding(.horizontal, 12)
        .padding(.bottom, 20)
    }
    
    // MARK: - Data Refresh
    
    private func refreshData() {
        performanceVM.loadMatches(from: matchVM.allMatches)
        momentumVM.loadMatches(from: matchVM.allMatches)
        achievementVM.checkAchievements(matches: matchVM.allMatches)
    }
}

// MARK: - Rugby Tab Bar Item

private struct RugbyTabBarItem: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.pureWhite)
                            .frame(width: 44, height: 28)
                            .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                    }
                    
                    Image(systemName: tab.icon)
                        .font(.system(size: isSelected ? 20 : 18, weight: isSelected ? .bold : .medium))
                        .foregroundColor(isSelected ? .primaryRed : .pureWhite.opacity(0.7))
                }
                .frame(height: 28)
                
                Text(tab.shortTitle)
                    .font(.system(size: 9, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .pureWhite : .pureWhite.opacity(0.7))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(RugbyTabBarButtonStyle())
    }
}

// MARK: - Tab Bar Button Style

private struct RugbyTabBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Tab Item

enum TabItem: Int, CaseIterable {
    case matchTracker
    case performance
    case momentum
    case achievements
    case settings
    
    var title: String {
        switch self {
        case .matchTracker: return "Match"
        case .performance: return "Performance"
        case .momentum: return "Momentum"
        case .achievements: return "Achievements"
        case .settings: return "Settings"
        }
    }
    
    var shortTitle: String {
        switch self {
        case .matchTracker: return "Match"
        case .performance: return "Stats"
        case .momentum: return "Flow"
        case .achievements: return "Trophies"
        case .settings: return "Settings"
        }
    }
    
    var icon: String {
        switch self {
        case .matchTracker: return "clock.fill"
        case .performance: return "chart.bar.fill"
        case .momentum: return "waveform.path.ecg"
        case .achievements: return "trophy.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

#Preview {
    MainTabView()
}
