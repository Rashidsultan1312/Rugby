import SwiftUI

// MARK: - Achievement Type

enum AchievementType: String, Codable, CaseIterable, Identifiable {
    case firstMatch = "first_match"
    case redWall = "red_wall"
    case breakthrough = "breakthrough"
    case dominantHalf = "dominant_half"
    case captainMind = "captain_mind"
    case ironDefense = "iron_defense"
    case tryMachine = "try_machine"
    case setpieceMaster = "setpiece_master"
    case firstTry = "first_try"
    case conversionKing = "conversion_king"
    case scrumDominance = "scrum_dominance"
    case lineoutKing = "lineout_king"
    case turnoverHunter = "turnover_hunter"
    case brickWall = "brick_wall"
    case hatTrick = "hat_trick"
    case marathon = "marathon"
    case centurion = "centurion"
    case fiftyUp = "fifty_up"
    case momentumRising = "momentum_rising"
    case sharpshooter = "sharpshooter"
    case breakdownKing = "breakdown_king"
    case allRounder = "all_rounder"
    case setPieceSweep = "setpiece_sweep"
    case unstoppable = "unstoppable"
    case veteran = "veteran"
    case legend = "legend"
    case perfectTen = "perfect_ten"
    case doubleDouble = "double_double"
    case ironCurtain = "iron_curtain"
    case momentumMaster = "momentum_master"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .firstMatch: return "First Match Logged"
        case .redWall: return "Red Wall"
        case .breakthrough: return "Breakthrough"
        case .dominantHalf: return "Dominant Half"
        case .captainMind: return "Captain Mind"
        case .ironDefense: return "Iron Defense"
        case .tryMachine: return "Try Machine"
        case .setpieceMaster: return "Set Piece Master"
        case .firstTry: return "First Try"
        case .conversionKing: return "Conversion King"
        case .scrumDominance: return "Scrum Dominance"
        case .lineoutKing: return "Lineout King"
        case .turnoverHunter: return "Turnover Hunter"
        case .brickWall: return "Brick Wall"
        case .hatTrick: return "Hat Trick"
        case .marathon: return "Marathon"
        case .centurion: return "Centurion"
        case .fiftyUp: return "Fifty Up"
        case .momentumRising: return "Momentum Rising"
        case .sharpshooter: return "Sharpshooter"
        case .breakdownKing: return "Breakdown King"
        case .allRounder: return "All-Rounder"
        case .setPieceSweep: return "Set Piece Sweep"
        case .unstoppable: return "Unstoppable"
        case .veteran: return "Veteran"
        case .legend: return "Legend"
        case .perfectTen: return "Perfect Ten"
        case .doubleDouble: return "Double Double"
        case .ironCurtain: return "Iron Curtain"
        case .momentumMaster: return "Momentum Master"
        }
    }
    
    var description: String {
        switch self {
        case .firstMatch: return "Complete your first match"
        case .redWall: return "10 tackles in one match"
        case .breakthrough: return "3 breaks in one game"
        case .dominantHalf: return "Achieve momentum 3.0+ in a match"
        case .captainMind: return "Record 5 matches"
        case .ironDefense: return "15 tackles across all matches"
        case .tryMachine: return "Score 10 tries total"
        case .setpieceMaster: return "Win 20 set pieces total"
        case .firstTry: return "Score your first try"
        case .conversionKing: return "5 conversions in one match"
        case .scrumDominance: return "Win 5 scrums in one match"
        case .lineoutKing: return "Win 5 lineouts in one match"
        case .turnoverHunter: return "3 turnovers in one match"
        case .brickWall: return "15 tackles in one match"
        case .hatTrick: return "3 tries in one match"
        case .marathon: return "Complete a match 60+ minutes"
        case .centurion: return "100 total events across all matches"
        case .fiftyUp: return "50 total events recorded"
        case .momentumRising: return "Average momentum 2.0+ over 3 matches"
        case .sharpshooter: return "10 conversions total"
        case .breakdownKing: return "10 turnovers total"
        case .allRounder: return "1 try, 1 tackle & 1 break in one match"
        case .setPieceSweep: return "3 scrums and 3 lineouts in one match"
        case .unstoppable: return "Momentum 4.0+ in a single match"
        case .veteran: return "Complete 10 matches"
        case .legend: return "Complete 25 matches"
        case .perfectTen: return "10 tries in one match"
        case .doubleDouble: return "2 tries and 2 conversions in one match"
        case .ironCurtain: return "20 tackles in one match"
        case .momentumMaster: return "Momentum 2.5+ in 5 different matches"
        }
    }
    
    var icon: String {
        switch self {
        case .firstMatch: return "flag.fill"
        case .redWall: return "shield.fill"
        case .breakthrough: return "bolt.fill"
        case .dominantHalf: return "flame.fill"
        case .captainMind: return "brain.head.profile"
        case .ironDefense: return "lock.shield.fill"
        case .tryMachine: return "sportscourt.fill"
        case .setpieceMaster: return "person.3.fill"
        case .firstTry: return "star.fill"
        case .conversionKing: return "target"
        case .scrumDominance: return "person.3.fill"
        case .lineoutKing: return "arrow.up.circle.fill"
        case .turnoverHunter: return "arrow.triangle.2.circlepath"
        case .brickWall: return "rectangle.stack.fill"
        case .hatTrick: return "3.circle.fill"
        case .marathon: return "clock.fill"
        case .centurion: return "100.circle.fill"
        case .fiftyUp: return "50.circle.fill"
        case .momentumRising: return "waveform.path.ecg"
        case .sharpshooter: return "scope"
        case .breakdownKing: return "crown.fill"
        case .allRounder: return "circle.hexagongrid.fill"
        case .setPieceSweep: return "checkmark.circle.fill"
        case .unstoppable: return "bolt.circle.fill"
        case .veteran: return "medal.fill"
        case .legend: return "star.circle.fill"
        case .perfectTen: return "10.circle.fill"
        case .doubleDouble: return "square.stack.3d.up.fill"
        case .ironCurtain: return "shield.lefthalf.filled"
        case .momentumMaster: return "chart.line.uptrend.xyaxis"
        }
    }
    
    var color: Color {
        switch self {
        case .firstMatch: return .primaryRed
        case .redWall: return .deepRed
        case .breakthrough: return .accentCrimson
        case .dominantHalf: return .orange
        case .captainMind: return .primaryRed
        case .ironDefense: return .deepRed
        case .tryMachine: return .accentCrimson
        case .setpieceMaster: return .primaryRed
        case .firstTry: return .accentCrimson
        case .conversionKing: return .orange
        case .scrumDominance: return .deepRed
        case .lineoutKing: return .primaryRed
        case .turnoverHunter: return .green
        case .brickWall: return .deepRed
        case .hatTrick: return .accentCrimson
        case .marathon: return .primaryRed
        case .centurion: return .accentCrimson
        case .fiftyUp: return .primaryRed
        case .momentumRising: return .orange
        case .sharpshooter: return .accentCrimson
        case .breakdownKing: return .primaryRed
        case .allRounder: return .orange
        case .setPieceSweep: return .deepRed
        case .unstoppable: return .accentCrimson
        case .veteran: return .primaryRed
        case .legend: return .accentCrimson
        case .perfectTen: return .accentCrimson
        case .doubleDouble: return .primaryRed
        case .ironCurtain: return .deepRed
        case .momentumMaster: return .orange
        }
    }
}

// MARK: - Achievement Model

struct Achievement: Identifiable, Codable {
    let type: AchievementType
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    var id: String { type.rawValue }
    
    init(type: AchievementType, isUnlocked: Bool = false, unlockedDate: Date? = nil) {
        self.type = type
        self.isUnlocked = isUnlocked
        self.unlockedDate = unlockedDate
    }
}
