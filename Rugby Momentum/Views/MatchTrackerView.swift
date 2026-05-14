import SwiftUI

// MARK: - Match Tracker View

struct MatchTrackerView: View {
    @ObservedObject var matchVM: MatchViewModel
    @ObservedObject var achievementVM: AchievementViewModel
    
    @State private var showNewMatchSheet = false
    @State private var showEndConfirm = false
    
    var body: some View {
        ZStack {
            RugbyBackgroundView()
            
            if matchVM.isMatchActive {
                activeMatchView
            } else {
                noMatchView
            }
            
            // Flash effect overlay
            if matchVM.showFlashEffect {
                Color.accentCrimson
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .animation(.easeOut(duration: 0.3), value: matchVM.showFlashEffect)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showNewMatchSheet) {
            newMatchSheet
        }
        .overlay {
            if showEndConfirm {
                CustomConfirmPopup(
                    title: "End Match?",
                    message: "This will save the match and all recorded events.",
                    confirmTitle: "End Match",
                    confirmRole: .destructive,
                    onConfirm: {
                        showEndConfirm = false
                        matchVM.endMatch()
                        achievementVM.checkAchievements(matches: matchVM.allMatches)
                    },
                    onCancel: { showEndConfirm = false }
                )
            }
        }
    }
    
    // MARK: - Active Match View
    
    private var activeMatchView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Timer & Score
                matchHeader
                
                // Event Buttons
                eventButtons
                
                // Event History
                eventHistory
                
                // End Match Button
                Button(action: { showEndConfirm = true }) {
                    HStack {
                        Image(systemName: "flag.checkered")
                        Text("End Match")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.pureWhite)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.deepRed)
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
        }
        .scrollIndicators(.hidden)
    }
    
    // MARK: - Match Header
    
    private var matchHeader: some View {
        VStack(spacing: 12) {
            // Timer
            Text(matchVM.timerLabel)
                .font(.system(size: 56, weight: .bold, design: .monospaced))
                .foregroundColor(.pureWhite)
            
            Text("MIN \(matchVM.currentMinute)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.pureWhite.opacity(0.7))
            
            // Score
            HStack(spacing: 0) {
                // Home
                VStack(spacing: 4) {
                    Text(matchVM.currentMatch?.homeName ?? "Home")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.pureWhite.opacity(0.8))
                    Text("\(matchVM.homeScore)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.pureWhite)
                }
                .frame(maxWidth: .infinity)
                
                // Separator
                VStack {
                    Text("VS")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.pureWhite.opacity(0.5))
                }
                .frame(width: 50)
                
                // Away
                VStack(spacing: 4) {
                    Text(matchVM.currentMatch?.awayName ?? "Away")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.pureWhite.opacity(0.8))
                    
                    HStack(spacing: 12) {
                        Button(action: { matchVM.decrementAwayScore() }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.pureWhite.opacity(0.6))
                        }
                        
                        Text("\(matchVM.awayScore)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.pureWhite)
                        
                        Button(action: { matchVM.incrementAwayScore() }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.pureWhite.opacity(0.6))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.pureWhite.opacity(0.1))
            )
            .padding(.horizontal)
        }
        .padding(.top, 16)
    }
    
    // MARK: - Event Buttons
    
    private var eventButtons: some View {
        VStack(spacing: 12) {
            Text("LOG EVENT")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.pureWhite.opacity(0.6))
                .tracking(2)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                ForEach(EventType.allCases) { eventType in
                    Button(action: {
                        matchVM.addEvent(eventType)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: eventType.icon)
                                .font(.system(size: 16))
                            Text(eventType.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(eventType.isPositive ? .primaryRed : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.pureWhite)
                                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Event History
    
    private var eventHistory: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MATCH EVENTS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.pureWhite.opacity(0.6))
                .tracking(2)
                .padding(.horizontal)
            
            if matchVM.recentEvents.isEmpty {
                Text("No events recorded yet")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.pureWhite.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
            } else {
                ForEach(matchVM.recentEvents) { event in
                    HStack(spacing: 12) {
                        // Minute badge
                        Text(event.minuteLabel)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.primaryRed)
                            .frame(width: 40)
                        
                        // Icon
                        Image(systemName: event.type.icon)
                            .font(.system(size: 14))
                            .foregroundColor(event.type.color)
                            .frame(width: 24)
                        
                        // Label
                        Text(event.type.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Score impact
                        if event.type.scorePoints > 0 {
                            Text("+\(event.type.scorePoints)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.primaryRed)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.pureWhite)
                    )
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - No Match View
    
    private var noMatchView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.pureWhite.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "sportscourt.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.pureWhite)
            }
            
            VStack(spacing: 8) {
                Text("Match Tracker")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.pureWhite)
                
                Text("Start a new match to track events")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.pureWhite.opacity(0.7))
            }
            
            Button(action: { showNewMatchSheet = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("New Match")
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primaryRed)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.pureWhite)
                        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                )
            }
            .padding(.horizontal, 40)
            
            // Match history
            if !matchVM.completedMatches.isEmpty {
                matchHistorySection
            }
            
            Spacer()
        }
    }
    
    // MARK: - Match History
    
    private var matchHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT MATCHES")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.pureWhite.opacity(0.6))
                .tracking(2)
                .padding(.horizontal)
            
            ForEach(matchVM.completedMatches.suffix(5).reversed()) { match in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(match.homeName) vs \(match.awayName)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                        Text(match.dateLabel)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(match.homeScore) - \(match.awayScore)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primaryRed)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.pureWhite)
                        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                )
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - New Match Sheet
    
    private var newMatchSheet: some View {
        ZStack {
            Color.softGray.ignoresSafeArea()
            
            VStack(spacing: 0) {
                CustomSheetHeader(title: "New Match") {
                    showNewMatchSheet = false
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Home Team")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                CustomTextField(
                                    placeholder: "Home team name",
                                    text: $matchVM.homeName
                                )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Away Team")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                CustomTextField(
                                    placeholder: "Away team name",
                                    text: $matchVM.awayName
                                )
                            }
                        }
                        .padding()
                        
                        Button(action: {
                            HapticService.shared.mediumImpact()
                            matchVM.startMatch()
                            showNewMatchSheet = false
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Match")
                            }
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.pureWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(LinearGradient.redGradient)
                                    .shadow(color: .primaryRed.opacity(0.3), radius: 10, y: 5)
                            )
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
        }
    }
}
