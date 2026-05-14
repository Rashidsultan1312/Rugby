import SwiftUI
import Charts

// MARK: - Momentum View

struct MomentumView: View {
    @ObservedObject var momentumVM: MomentumViewModel
    
    var body: some View {
        ZStack {
            RugbyBackgroundView()
            
            // Spark glow effect
            if momentumVM.showSparkEffect {
                RadialGradient(
                    colors: [.accentCrimson.opacity(0.3), .clear],
                    center: .center,
                    startRadius: 50,
                    endRadius: 400
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: momentumVM.showSparkEffect)
            }
            
            if momentumVM.matches.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        matchSelector
                        momentumGauge
                        waveSection
                        timelineChart
                        peakMomentsSection
                        Spacer(minLength: 20)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 50))
                .foregroundColor(.pureWhite.opacity(0.5))
            
            Text("No Momentum Data")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.pureWhite)
            
            Text("Complete a match to analyze momentum")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.pureWhite.opacity(0.7))
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("MOMENTUM")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.pureWhite.opacity(0.6))
                .tracking(3)
            
            Text("Game Flow Analysis")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.pureWhite.opacity(0.8))
        }
        .padding(.top, 16)
    }
    
    // MARK: - Match Selector
    
    private var matchSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(momentumVM.matches) { match in
                    Button(action: {
                        momentumVM.selectMatch(match)
                        HapticService.shared.selectionChanged()
                    }) {
                        VStack(spacing: 4) {
                            Text("\(match.homeName)")
                                .font(.system(size: 12, weight: .semibold))
                            Text("\(match.homeScore)-\(match.awayScore)")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(
                            momentumVM.selectedMatch?.id == match.id
                            ? .primaryRed : .pureWhite
                        )
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    momentumVM.selectedMatch?.id == match.id
                                    ? Color.pureWhite : Color.pureWhite.opacity(0.15)
                                )
                        )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Momentum Gauge
    
    private var momentumGauge: some View {
        VStack(spacing: 16) {
            // Large momentum index
            ZStack {
                Circle()
                    .stroke(Color.pureWhite.opacity(0.2), lineWidth: 8)
                    .frame(width: 140, height: 140)
                
                Circle()
                    .trim(from: 0, to: min(CGFloat(momentumVM.currentMomentumIndex) / 5.0, 1.0))
                    .stroke(
                        LinearGradient(
                            colors: [.accentCrimson, .primaryRed],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: momentumVM.currentMomentumIndex)
                
                VStack(spacing: 4) {
                    Text(momentumVM.formattedMomentumIndex)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.pureWhite)
                    
                    Text(momentumVM.momentumLevel.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.accentCrimson)
                }
            }
            
            // Stats row
            HStack(spacing: 30) {
                VStack(spacing: 4) {
                    Text("Average")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.pureWhite.opacity(0.6))
                    Text(momentumVM.formattedAverageMomentum)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.pureWhite)
                }
                
                Rectangle()
                    .fill(Color.pureWhite.opacity(0.3))
                    .frame(width: 1, height: 30)
                
                VStack(spacing: 4) {
                    Text("Best")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.pureWhite.opacity(0.6))
                    Text(String(format: "%.1f", momentumVM.bestMomentumIndex))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.pureWhite)
                }
                
                Rectangle()
                    .fill(Color.pureWhite.opacity(0.3))
                    .frame(width: 1, height: 30)
                
                VStack(spacing: 4) {
                    Text("Peaks")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.pureWhite.opacity(0.6))
                    Text("\(momentumVM.peakMoments.count)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.pureWhite)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.pureWhite.opacity(0.1))
        )
        .padding(.horizontal)
    }
    
    // MARK: - Wave Section
    
    private var waveSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PRESSURE WAVE")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.pureWhite.opacity(0.6))
                .tracking(2)
                .padding(.horizontal)
            
            MomentumWaveView(
                phase: momentumVM.wavePhase,
                intensity: momentumVM.momentumLevel.intensity
            )
            .frame(height: 80)
            .padding(.horizontal)
        }
    }
    
    // MARK: - Timeline Chart
    
    private var timelineChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MOMENTUM OVER TIME")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.pureWhite.opacity(0.6))
                .tracking(2)
            
            if !momentumVM.timeline.isEmpty {
                Chart {
                    ForEach(momentumVM.timeline) { point in
                        LineMark(
                            x: .value("Minute", point.minuteLabel),
                            y: .value("Momentum", point.value)
                        )
                        .foregroundStyle(Color.primaryRed)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                        
                        AreaMark(
                            x: .value("Minute", point.minuteLabel),
                            y: .value("Momentum", point.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primaryRed.opacity(0.3), .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel()
                            .foregroundStyle(Color.secondary)
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.pureWhite)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        )
        .padding(.horizontal)
    }
    
    // MARK: - Peak Moments
    
    private var peakMomentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PEAK MOMENTS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.pureWhite.opacity(0.6))
                .tracking(2)
                .padding(.horizontal)
            
            if momentumVM.peakMoments.isEmpty {
                Text("No peak moments detected")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.pureWhite.opacity(0.5))
                    .padding(.horizontal)
            } else {
                ForEach(momentumVM.peakMoments) { peak in
                    HStack(spacing: 12) {
                        // Flame indicator
                        Image(systemName: peak.isDominant ? "flame.fill" : "bolt.fill")
                            .font(.system(size: 18))
                            .foregroundColor(peak.isDominant ? .accentCrimson : .primaryRed)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.pureWhite.opacity(0.15))
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(peak.label)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.pureWhite)
                            
                            Text("Momentum: \(String(format: "%.1f", peak.momentum))")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.pureWhite.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        if peak.isDominant {
                            Text("DOMINANT")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.accentCrimson)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.accentCrimson.opacity(0.2))
                                )
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Momentum Wave View

struct MomentumWaveView: View {
    let phase: Double
    let intensity: Double
    
    var body: some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height
            let midY = height / 2
            
            var path = Path()
            path.move(to: CGPoint(x: 0, y: midY))
            
            for x in stride(from: 0, through: width, by: 2) {
                let relativeX = Double(x / width)
                let phaseValue = Double(phase)
                let sine = CGFloat(sin(relativeX * .pi * 4.0 + phaseValue * 2.0))
                let amplitude = height * 0.3 * CGFloat(intensity)
                let y = midY + sine * amplitude
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            context.stroke(
                path,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.accentCrimson.opacity(0.8),
                        Color.primaryRed,
                        Color.accentCrimson.opacity(0.8)
                    ]),
                    startPoint: .zero,
                    endPoint: CGPoint(x: width, y: 0)
                ),
                lineWidth: 3
            )
            
            // Fill below wave
            var fillPath = path
            fillPath.addLine(to: CGPoint(x: width, y: height))
            fillPath.addLine(to: CGPoint(x: 0, y: height))
            fillPath.closeSubpath()
            
            context.fill(
                fillPath,
                with: .linearGradient(
                    Gradient(colors: [
                        Color.accentCrimson.opacity(0.2 * intensity),
                        Color.clear
                    ]),
                    startPoint: CGPoint(x: 0, y: midY - 20),
                    endPoint: CGPoint(x: 0, y: height)
                )
            )
        }
    }
}
