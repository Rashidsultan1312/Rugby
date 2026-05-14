import UIKit

// MARK: - Haptic Feedback Service

final class HapticService {
    static let shared = HapticService()
    
    private init() {}
    
    /// Light impact for button taps
    func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Medium impact for event logging
    func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Heavy impact for scoring events
    func heavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Success notification for achievements
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Warning notification
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }
    
    /// Error notification
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    /// Selection changed feedback
    func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    /// Haptic for event type based on importance
    func eventHaptic(for type: EventType) {
        switch type {
        case .tryScore:
            heavyImpact()
        case .conversion, .breakThrough:
            mediumImpact()
        case .turnover, .scrumWin, .lineoutWin:
            mediumImpact()
        case .tackle:
            lightImpact()
        case .missedTackle:
            warning()
        }
    }
}
