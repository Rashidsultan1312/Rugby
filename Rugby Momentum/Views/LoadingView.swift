import SwiftUI

// MARK: - Loading View

struct LoadingView: View {
    @State private var ballOffset: CGFloat = -200
    @State private var ballRotation: Double = 0
    @State private var trailWidth: CGFloat = 0
    @State private var showLogo: Bool = false
    @State private var logoOpacity: Double = 0
    @State private var showSubtitle: Bool = false
    @State private var pulseScale: CGFloat = 1.0
    
    var onFinished: () -> Void
    
    var body: some View {
        ZStack {
            RugbyBackgroundView(overlayOpacity: 0.45)
            
            VStack(spacing: 30) {
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.accentCrimson.opacity(0.6))
                        .frame(width: trailWidth, height: 4)
                        .offset(x: -(200 - trailWidth / 2))
                    
                    RugbyBallShape()
                        .fill(Color.pureWhite)
                        .frame(width: 50, height: 30)
                        .rotationEffect(.degrees(ballRotation))
                        .offset(x: ballOffset)
                        .shadow(color: .accentCrimson.opacity(0.5), radius: 10)
                }
                .frame(height: 50)
                
                VStack(spacing: 12) {
                    Text("RUGBY")
                        .font(.system(size: 42, weight: .bold, design: .default))
                        .foregroundColor(.pureWhite)
                    
                    Text("MOMENTUM")
                        .font(.system(size: 42, weight: .bold, design: .default))
                        .foregroundColor(.accentCrimson)
                }
                .opacity(logoOpacity)
                .scaleEffect(showLogo ? 1.0 : 0.8)
                
                // Subtitle
                Text("Track Every Impact")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.pureWhite.opacity(0.8))
                    .opacity(showSubtitle ? 1 : 0)
                
                Spacer()
                
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.pureWhite)
                            .frame(width: 8, height: 8)
                            .scaleEffect(pulseScale)
                            .animation(
                                .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                                value: pulseScale
                            )
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        pulseScale = 0.5
        
        withAnimation(.easeInOut(duration: 1.5)) {
            ballOffset = 0
            ballRotation = 720
            trailWidth = 200
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showLogo = true
                logoOpacity = 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeIn(duration: 0.5)) {
                showSubtitle = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            onFinished()
        }
    }
}

// MARK: - Rugby Ball Shape

struct RugbyBallShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        path.move(to: CGPoint(x: center.x - width/2, y: center.y))
        path.addQuadCurve(
            to: CGPoint(x: center.x + width/2, y: center.y),
            control: CGPoint(x: center.x, y: center.y - height/2)
        )
        path.addQuadCurve(
            to: CGPoint(x: center.x - width/2, y: center.y),
            control: CGPoint(x: center.x, y: center.y + height/2)
        )
        
        return path
    }
}

// MARK: - Field Lines Background

struct FieldLinesBackground: View {
    var body: some View {
        GeometryReader { geometry in
            let lineCount = 10
            let spacing = geometry.size.width / CGFloat(lineCount)
            
            ZStack {
                ForEach(0..<lineCount, id: \.self) { i in
                    Rectangle()
                        .fill(Color.pureWhite)
                        .frame(width: 1)
                        .position(x: CGFloat(i) * spacing, y: geometry.size.height / 2)
                        .frame(height: geometry.size.height)
                }
                
                Rectangle()
                    .fill(Color.pureWhite)
                    .frame(width: 2)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .frame(height: geometry.size.height)
                
                Rectangle()
                    .fill(Color.pureWhite)
                    .frame(height: 1)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .frame(width: geometry.size.width)
            }
        }
    }
}
