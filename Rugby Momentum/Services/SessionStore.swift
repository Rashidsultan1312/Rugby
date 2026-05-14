import Foundation
import WebKit

enum SessionStore {
    static func restoreCookies(to store: WKHTTPCookieStore) {
        guard let cookies = HTTPCookieStorage.shared.cookies else { return }
        for cookie in cookies {
            store.setCookie(cookie)
        }
    }

    static func persistCookies(from store: WKHTTPCookieStore) {
        store.getAllCookies { cookies in
            for cookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
        }
    }
}
