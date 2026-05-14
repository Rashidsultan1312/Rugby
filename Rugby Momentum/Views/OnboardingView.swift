import SwiftUI

// MARK: - Onboarding View

struct OnboardingView: View {
    var onComplete: () -> Void
    
    @State private var showContent = false
    @State private var showButton = false
    
    var body: some View {
        ZStack {
            RugbyBackgroundView(overlayOpacity: 0.4)
            
            VStack(spacing: 40) {
                Spacer()
                
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.pureWhite.opacity(0.15))
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .fill(Color.pureWhite.opacity(0.25))
                        .frame(width: 110, height: 110)
                    
                    Image(systemName: "sportscourt.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.pureWhite)
                }
                .scaleEffect(showContent ? 1.0 : 0.5)
                .opacity(showContent ? 1.0 : 0)
                
                // Title and body
                VStack(spacing: 16) {
                    Text("Track Every Impact.")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.pureWhite)
                        .multilineTextAlignment(.center)
                    
                    Text("Measure momentum.\nAnalyze performance.\nImprove your game.")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.pureWhite.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                }
                .offset(y: showContent ? 0 : 30)
                .opacity(showContent ? 1.0 : 0)
                
                Spacer()
                
                // Get Started button
                Button(action: {
                    HapticService.shared.mediumImpact()
                    onComplete()
                }) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primaryRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.pureWhite)
                                .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
                        )
                }
                .padding(.horizontal, 40)
                .opacity(showButton ? 1.0 : 0)
                .offset(y: showButton ? 0 : 20)
                
                Spacer()
                    .frame(height: 40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                showContent = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.8)) {
                showButton = true
            }
        }
    }
}
