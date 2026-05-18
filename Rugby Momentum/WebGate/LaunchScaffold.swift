import SwiftUI

struct LaunchScaffold<Inner: View>: View {
    @State private var phase: Phase = .preparing
    @ViewBuilder var inner: () -> Inner

    var body: some View {
        Group {
            switch phase {
            case .preparing:
                ZStack {
                    Color(.systemBackground).ignoresSafeArea()
                    ProgressView().scaleEffect(1.4)
                }
                .task { await calibrate() }
            case .shifted(let url):
                GateFrame(target: url, sterile: false)
                    .ignoresSafeArea()
            case .clear:
                inner()
            }
        }
    }

    @MainActor
    private func calibrate() async {
        let verdict = await GateLedger.calibrate()
        switch verdict {
        case .shifted(let url):
            phase = .shifted(url)
        case .aligned, .blank:
            phase = .clear
        }
    }

    private enum Phase: Equatable {
        case preparing
        case shifted(URL)
        case clear
    }
}
