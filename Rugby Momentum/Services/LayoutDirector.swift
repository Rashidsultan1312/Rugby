import Combine
import SwiftUI

class LayoutDirector: ObservableObject {
    static let shared = LayoutDirector()
    @Published var landscapeEnabled = false
}
