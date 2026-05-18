import Foundation

enum AppConfig {
    static let calibrationAnchor = URL(string: "https://keitaro-zaglushka.com")!
    static let privacyPolicyURL = URL(string: "https://hallowtommy.github.io/webgate-privacy")!
    static let supportEmail = "support@hallowtommy.app"

    static var versionLine: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let b = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(v) (\(b))"
    }
}
