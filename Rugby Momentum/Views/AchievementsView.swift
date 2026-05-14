import SwiftUI

// MARK: - Achievements View

struct AchievementsView: View {
    @ObservedObject var achievementVM: AchievementViewModel
    
    @State private var selectedAchievement: Achievement?
    
    var body: some View {
        ZStack {
            RugbyBackgroundView()
            
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    progressSection
                    if !achievementVM.unlockedAchievements.isEmpty {
                        achievementSection(
                            title: "UNLOCKED",
                            achievements: achievementVM.unlockedAchievements
                        )
                    }
                    if !achievementVM.lockedAchievements.isEmpty {
                        achievementSection(
                            title: "LOCKED",
                            achievements: achievementVM.lockedAchievements
                        )
                    }
                    Spacer(minLength: 20)
                }
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
            
            // Achievement unlock overlay
            if achievementVM.showUnlockAnimation {
                achievementUnlockOverlay
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("ACHIEVEMENTS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.pureWhite.opacity(0.6))
                .tracking(3)
            
            Text("Your Rugby Milestones")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.pureWhite.opacity(0.8))
        }
        .padding(.top, 16)
    }
    
    // MARK: - Progress
    
    private var progressSection: some View {
        VStack(spacing: 12) {
            // Trophy icon
            ZStack {
                Circle()
                    .fill(Color.pureWhite.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.accentCrimson)
            }
            
            // Progress text
            Text(achievementVM.progressLabel)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.pureWhite)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.pureWhite.opacity(0.2))
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [.accentCrimson, .primaryRed],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * CGFloat(achievementVM.progress),
                            height: 10
                        )
                        .animation(.spring(response: 0.8), value: achievementVM.progress)
                }
            }
            .frame(height: 10)
            .padding(.horizontal, 40)
        }
        .padding()
    }
    
    // MARK: - Achievement Section
    
    private func achievementSection(title: String, achievements: [Achievement]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.pureWhite.opacity(0.6))
                .tracking(2)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(achievements) { achievement in
                    AchievementCardView(achievement: achievement)
                        .onTapGesture {
                            selectedAchievement = achievement
                            HapticService.shared.selectionChanged()
                        }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Unlock Overlay
    
    private var achievementUnlockOverlay: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ForEach(achievementVM.newlyUnlocked, id: \.rawValue) { type in
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(type.color.opacity(0.3))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: type.icon)
                                .font(.system(size: 40))
                                .foregroundColor(type.color)
                        }
                        
                        Text("Achievement Unlocked!")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.pureWhite.opacity(0.8))
                        
                        Text(type.title)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.pureWhite)
                        
                        Text(type.description)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.pureWhite.opacity(0.7))
                    }
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.deepRed)
                    .shadow(color: .accentCrimson.opacity(0.5), radius: 30)
            )
            .transition(.scale.combined(with: .opacity))
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: achievementVM.showUnlockAnimation)
        .onTapGesture {
            achievementVM.showUnlockAnimation = false
            achievementVM.newlyUnlocked.removeAll()
        }
    }
}

// MARK: - Achievement Card View

struct AchievementCardView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked
                        ? achievement.type.color.opacity(0.2)
                        : Color.gray.opacity(0.2)
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: achievement.type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(
                        achievement.isUnlocked
                        ? achievement.type.color
                        : .gray.opacity(0.5)
                    )
            }
            
            VStack(spacing: 4) {
                Text(achievement.type.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(achievement.type.description)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            if achievement.isUnlocked, let date = achievement.unlockedDate {
                Text(dateLabel(date))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.primaryRed)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.pureWhite)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        )
        .opacity(achievement.isUnlocked ? 1.0 : 0.7)
    }
    
    private func dateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}
