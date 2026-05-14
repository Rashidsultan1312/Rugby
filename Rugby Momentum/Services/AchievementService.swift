import Foundation

// MARK: - Achievement Service

final class AchievementService {
    static let shared = AchievementService()
    
    private let userDefaultsKey = "rugby_achievements"
    
    private init() {}
    
    // MARK: - Persistence
    
    /// Load achievements from UserDefaults
    func loadAchievements() -> [Achievement] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let achievements = try? JSONDecoder().decode([Achievement].self, from: data) else {
            return AchievementType.allCases.map { Achievement(type: $0) }
        }
        
        var loaded = achievements
        for type in AchievementType.allCases {
            if !loaded.contains(where: { $0.type == type }) {
                loaded.append(Achievement(type: type))
            }
        }
        
        return loaded
    }
    
    /// Save achievements to UserDefaults
    func saveAchievements(_ achievements: [Achievement]) {
        if let data = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    // MARK: - Achievement Checking
    
    /// Check and unlock achievements based on current match data
    func checkAchievements(matches: [Match]) -> [AchievementType] {
        var achievements = loadAchievements()
        var newlyUnlocked: [AchievementType] = []
        
        for index in achievements.indices {
            if !achievements[index].isUnlocked {
                let shouldUnlock = checkCondition(for: achievements[index].type, matches: matches)
                if shouldUnlock {
                    achievements[index].isUnlocked = true
                    achievements[index].unlockedDate = Date()
                    newlyUnlocked.append(achievements[index].type)
                }
            }
        }
        
        if !newlyUnlocked.isEmpty {
            saveAchievements(achievements)
        }
        
        return newlyUnlocked
    }
    
    /// Check if a specific achievement condition is met
    private func checkCondition(for type: AchievementType, matches: [Match]) -> Bool {
        let completedMatches = matches.filter { $0.isCompleted }
        let totalEvents = completedMatches.reduce(0) { $0 + $1.totalEvents }
        let totalTries = completedMatches.reduce(0) { $0 + $1.count(of: .tryScore) }
        let totalTackles = completedMatches.reduce(0) { $0 + $1.count(of: .tackle) }
        let totalConversions = completedMatches.reduce(0) { $0 + $1.count(of: .conversion) }
        let totalTurnovers = completedMatches.reduce(0) { $0 + $1.count(of: .turnover) }
        
        switch type {
        case .firstMatch:
            return completedMatches.count >= 1
            
        case .redWall:
            return completedMatches.contains { $0.count(of: .tackle) >= 10 }
            
        case .breakthrough:
            return completedMatches.contains { $0.count(of: .breakThrough) >= 3 }
            
        case .dominantHalf:
            return completedMatches.contains { match in
                MomentumService.shared.calculateMomentumIndex(for: match) >= 3.0
            }
            
        case .captainMind:
            return completedMatches.count >= 5
            
        case .ironDefense:
            return totalTackles >= 15
            
        case .tryMachine:
            return totalTries >= 10
            
        case .setpieceMaster:
            let totalSetPiece = completedMatches.reduce(0) {
                $0 + $1.count(of: .scrumWin) + $1.count(of: .lineoutWin)
            }
            return totalSetPiece >= 20
            
        case .firstTry:
            return totalTries >= 1
            
        case .conversionKing:
            return completedMatches.contains { $0.count(of: .conversion) >= 5 }
            
        case .scrumDominance:
            return completedMatches.contains { $0.count(of: .scrumWin) >= 5 }
            
        case .lineoutKing:
            return completedMatches.contains { $0.count(of: .lineoutWin) >= 5 }
            
        case .turnoverHunter:
            return completedMatches.contains { $0.count(of: .turnover) >= 3 }
            
        case .brickWall:
            return completedMatches.contains { $0.count(of: .tackle) >= 15 }
            
        case .hatTrick:
            return completedMatches.contains { $0.count(of: .tryScore) >= 3 }
            
        case .marathon:
            return completedMatches.contains { $0.duration >= 60 * 60 }
            
        case .centurion:
            return totalEvents >= 100
            
        case .fiftyUp:
            return totalEvents >= 50
            
        case .momentumRising:
            guard completedMatches.count >= 3 else { return false }
            let avg = completedMatches.reduce(0.0) { $0 + MomentumService.shared.calculateMomentumIndex(for: $1) } / Double(completedMatches.count)
            return avg >= 2.0
            
        case .sharpshooter:
            return totalConversions >= 10
            
        case .breakdownKing:
            return totalTurnovers >= 10
            
        case .allRounder:
            return completedMatches.contains { match in
                match.count(of: .tryScore) >= 1 &&
                match.count(of: .tackle) >= 1 &&
                match.count(of: .breakThrough) >= 1
            }
            
        case .setPieceSweep:
            return completedMatches.contains { match in
                match.count(of: .scrumWin) >= 3 && match.count(of: .lineoutWin) >= 3
            }
            
        case .unstoppable:
            return completedMatches.contains { match in
                MomentumService.shared.calculateMomentumIndex(for: match) >= 4.0
            }
            
        case .veteran:
            return completedMatches.count >= 10
            
        case .legend:
            return completedMatches.count >= 25
            
        case .perfectTen:
            return completedMatches.contains { $0.count(of: .tryScore) >= 10 }
            
        case .doubleDouble:
            return completedMatches.contains { match in
                match.count(of: .tryScore) >= 2 && match.count(of: .conversion) >= 2
            }
            
        case .ironCurtain:
            return completedMatches.contains { $0.count(of: .tackle) >= 20 }
            
        case .momentumMaster:
            let highMomentumCount = completedMatches.filter { match in
                MomentumService.shared.calculateMomentumIndex(for: match) >= 2.5
            }.count
            return highMomentumCount >= 5
        }
    }
    
    // MARK: - Reset
    
    /// Reset all achievements
    func resetAchievements() {
        let fresh = AchievementType.allCases.map { Achievement(type: $0) }
        saveAchievements(fresh)
    }
}
