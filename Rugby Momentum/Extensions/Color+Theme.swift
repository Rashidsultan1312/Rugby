import SwiftUI

// MARK: - Rugby Momentum Color Theme: Red Force Arena

extension Color {
    /// Primary Red: #D62828
    static let primaryRed = Color(red: 214/255, green: 40/255, blue: 40/255)
    
    /// Deep Red: #9B1C1C
    static let deepRed = Color(red: 155/255, green: 28/255, blue: 28/255)
    
    /// Pure White: #FFFFFF
    static let pureWhite = Color.white
    
    /// Soft Gray: #F2F2F2
    static let softGray = Color(red: 242/255, green: 242/255, blue: 242/255)
    
    /// Accent Crimson Glow: #FF4D4D
    static let accentCrimson = Color(red: 1.0, green: 77/255, blue: 77/255)
}

// MARK: - Theme Gradients

extension LinearGradient {
    /// Red gradient for buttons and accents
    static let redGradient = LinearGradient(
        colors: [.primaryRed, .deepRed],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    /// White to red gradient for special buttons
    static let whiteToRed = LinearGradient(
        colors: [.pureWhite, .primaryRed],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Background gradient
    static let backgroundGradient = LinearGradient(
        colors: [.primaryRed, .deepRed],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// Subtle card gradient
    static let cardGradient = LinearGradient(
        colors: [.white, .softGray.opacity(0.5)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
