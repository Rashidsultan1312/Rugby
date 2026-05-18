import Foundation

enum AppConfig {
    static let calibrationAnchor = URL(string: "https://plamstro.com/msyyht")!
    static let privacyPolicyURL = URL(string: "https://www.termsfeed.com/live/e442920c-d7cd-4748-839a-0e0de24ad6f8")!
    static let supportEmail = "noahwatson22@icloud.com"

    static var versionLine: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(v) (\(b))"
    }
}
