import SwiftUI

// MARK: - Rugby Background (regbiBG — aspect ratio preserved, no stretch)

struct RugbyBackgroundView: View {
    /// Overlay opacity to keep UI readable (0 = no overlay, 1 = solid)
    var overlayOpacity: Double = 0.35
    
    var body: some View {
        ZStack {
            Image("regbiBG")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
            
            Color.primaryRed
                .opacity(overlayOpacity)
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}
