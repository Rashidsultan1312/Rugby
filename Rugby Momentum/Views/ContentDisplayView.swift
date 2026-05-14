import Combine
import SwiftUI
import WebKit

class RemoteContentViewModel: ObservableObject {
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var progress: Double = 0
    @Published var isActive = true
    @Published var hasFailed = false

    weak var webView: WKWebView?

    func goBack() { webView?.goBack() }
    func goForward() { webView?.goForward() }
    func refresh() { webView?.reload() }

    func retry(address: String) {
        hasFailed = false
        isActive = true
        if let dest = URL(string: address) {
            webView?.load(URLRequest(url: dest))
        }
    }
}

struct RemoteContentView: View {
    let url: String
    @StateObject private var vm = RemoteContentViewModel()

    var body: some View {
        VStack(spacing: 0) {
            toolbar

            ZStack {
                WebAdapter(address: url, vm: vm)

                if vm.hasFailed {
                    offlineScreen
                }
            }

            if vm.isActive && !vm.hasFailed {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 8)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.accentCrimson, .primaryRed],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, CGFloat(vm.progress) * UIScreen.main.bounds.width), height: 8)
                        .shadow(color: .accentCrimson.opacity(0.6), radius: 6)
                }
                .animation(.easeInOut(duration: 0.2), value: vm.progress)
            }
        }
        .background(Color.black)
        .ignoresSafeArea(edges: [.top, .bottom])
        .statusBarHidden(true)
        .onAppear { LayoutDirector.shared.landscapeEnabled = true }
        .onDisappear { LayoutDirector.shared.landscapeEnabled = false }
    }

    private var toolbar: some View {
        HStack(spacing: 32) {
            Button { vm.goBack() } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
            }
            .disabled(!vm.canGoBack)
            .opacity(vm.canGoBack ? 1.0 : 0.3)

            Button { vm.goForward() } label: {
                Image(systemName: "chevron.right")
                    .font(.title3.weight(.semibold))
            }
            .disabled(!vm.canGoForward)
            .opacity(vm.canGoForward ? 1.0 : 0.3)

            Spacer()

            Button { vm.refresh() } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.title3.weight(.semibold))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(Color.black)
        .padding(.top, 1)
    }

    private var offlineScreen: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(.accentCrimson.opacity(0.6))

            Text("Connection Error")
                .font(.title3.bold())
                .foregroundColor(.white)

            Text("Check your internet connection\nand try again")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            Button("Retry") { vm.retry(address: url) }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 14)
                .background(Color.primaryRed)
                .cornerRadius(12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct WebAdapter: UIViewRepresentable {
    let address: String
    let vm: RemoteContentViewModel

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.websiteDataStore = .default()

        SessionStore.restoreCookies(to: config.websiteDataStore.httpCookieStore)

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        context.coordinator.observeProgress(of: webView)

        if let dest = URL(string: address) {
            webView.load(URLRequest(url: dest))
        }

        DispatchQueue.main.async { vm.webView = webView }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Handler {
        Handler(vm: vm)
    }

    class Handler: NSObject, WKNavigationDelegate, WKUIDelegate {
        let vm: RemoteContentViewModel
        var progressToken: NSKeyValueObservation?
        var loadingToken: NSKeyValueObservation?

        init(vm: RemoteContentViewModel) {
            self.vm = vm
        }

        func observeProgress(of webView: WKWebView) {
            progressToken = webView.observe(\.estimatedProgress) { [weak self] view, _ in
                DispatchQueue.main.async { self?.vm.progress = view.estimatedProgress }
            }
            loadingToken = webView.observe(\.isLoading) { [weak self] view, _ in
                DispatchQueue.main.async { self?.vm.isActive = view.isLoading }
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            vm.canGoBack = webView.canGoBack
            vm.canGoForward = webView.canGoForward
            vm.hasFailed = false
            SessionStore.persistCookies(from: webView.configuration.websiteDataStore.httpCookieStore)
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            vm.canGoBack = webView.canGoBack
            vm.canGoForward = webView.canGoForward
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            vm.hasFailed = true
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            vm.hasFailed = true
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            let scheme = url.scheme ?? ""
            if ["mailto", "tel", "sms", "tg", "whatsapp"].contains(scheme) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil || navigationAction.targetFrame?.isMainFrame == false {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}
