import SwiftUI
import Charts

// MARK: - Performance View

struct PerformanceView: View {
    @ObservedObject var performanceVM: PerformanceViewModel
    
    var body: some View {
        ZStack {
            RugbyBackgroundView()
            
            if performanceVM.matches.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        statCardsGrid
                        barChartSection
                        pieChartSection
                        radarChartSection
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
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 50))
                .foregroundColor(.pureWhite.opacity(0.5))
            
            Text("No Performance Data")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.pureWhite)
            
            Text("Complete a match to see your stats")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.pureWhite.opacity(0.7))
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("PERFORMANCE")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.pureWhite.opacity(0.6))
                .tracking(3)
            
            Text("\(performanceVM.matches.count) Matches Analyzed")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.pureWhite.opacity(0.8))
        }
        .padding(.top, 16)
    }
    
    // MARK: - Stat Cards
    
    private var statCardsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(performanceVM.statCards) { card in
                StatCardView(card: card)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Bar Chart Section
    
    private var barChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MATCH OVERVIEW")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.pureWhite.opacity(0.6))
                .tracking(2)
            
            VStack(alignment: .leading, spacing: 8) {
                // Metric selector (custom segmented control)
                RugbySegmentedControl(
                    options: Array(PerformanceMetric.allCases),
                    selection: $performanceVM.selectedMetric,
                    label: { $0.rawValue }
                )
                .padding(.bottom, 4)
                
                Chart {
                    ForEach(performanceVM.matchStats) { stat in
                        BarMark(
                            x: .value("Match", stat.label),
                            y: .value(
                                performanceVM.selectedMetric.rawValue,
                                metricValue(for: stat)
                            )
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primaryRed, .accentCrimson],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .cornerRadius(6)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 200)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.pureWhite)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            )
        }
        .padding(.horizontal)
    }
    
    private func metricValue(for stat: MatchStat) -> Double {
        switch performanceVM.selectedMetric {
        case .tries: return Double(stat.tries)
        case .tackles: return Double(stat.tackles)
        case .momentum: return stat.momentum
        }
    }
    
    // MARK: - Pie Chart Section
    
    private var pieChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EVENT DISTRIBUTION")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.pureWhite.opacity(0.6))
                .tracking(2)
            
            VStack {
                CustomPieChart(data: performanceVM.eventDistribution)
                    .frame(height: 220)
                
                // Legend
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(performanceVM.eventDistribution) { item in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(item.type.color)
                                .frame(width: 10, height: 10)
                            Text(item.type.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(item.count)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.pureWhite)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Radar Chart Section
    
    private var radarChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SKILL RATINGS")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.pureWhite.opacity(0.6))
                .tracking(2)
            
            VStack {
                RadarChartView(ratings: performanceVM.skillRatings)
                    .frame(height: 260)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.pureWhite)
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - Stat Card View

struct StatCardView: View {
    let card: StatCard
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: card.icon)
                .font(.system(size: 22))
                .foregroundColor(.primaryRed)
            
            Text(card.value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Text(card.title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.pureWhite)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        )
    }
}

// MARK: - Custom Pie Chart

struct CustomPieChart: View {
    let data: [EventDistribution]
    
    private var total: Int {
        data.reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 10
            
            ZStack {
                ForEach(Array(sliceData.enumerated()), id: \.offset) { index, slice in
                    PieSlice(
                        startAngle: slice.start,
                        endAngle: slice.end
                    )
                    .fill(data[index].type.color)
                    .frame(width: radius * 2, height: radius * 2)
                    .position(center)
                }
                
                // Center circle for donut style
                Circle()
                    .fill(Color.pureWhite)
                    .frame(width: radius, height: radius)
                    .position(center)
                
                // Center text
                VStack(spacing: 2) {
                    Text("\(total)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primaryRed)
                    Text("Events")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .position(center)
            }
        }
    }
    
    private var sliceData: [(start: Angle, end: Angle)] {
        var slices: [(start: Angle, end: Angle)] = []
        var currentAngle: Double = -90
        
        for item in data {
            let percentage = Double(item.count) / Double(max(total, 1))
            let degrees = percentage * 360
            slices.append((
                start: .degrees(currentAngle),
                end: .degrees(currentAngle + degrees)
            ))
            currentAngle += degrees
        }
        
        return slices
    }
}

// MARK: - Pie Slice Shape

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Radar Chart View

struct RadarChartView: View {
    let ratings: [SkillRating]
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 30
            let count = ratings.count
            
            ZStack {
                // Grid lines
                ForEach(1..<5) { level in
                    RadarGridShape(sides: count, scale: CGFloat(level) / 4.0)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        .frame(width: radius * 2, height: radius * 2)
                        .position(center)
                }
                
                // Data shape
                RadarDataShape(
                    values: ratings.map { $0.value / 100.0 },
                    sides: count
                )
                .fill(Color.primaryRed.opacity(0.2))
                .frame(width: radius * 2, height: radius * 2)
                .position(center)
                
                RadarDataShape(
                    values: ratings.map { $0.value / 100.0 },
                    sides: count
                )
                .stroke(Color.primaryRed, lineWidth: 2)
                .frame(width: radius * 2, height: radius * 2)
                .position(center)
                
                // Data points
                ForEach(Array(ratings.enumerated()), id: \.offset) { index, rating in
                    let angle = angleFor(index: index, total: count)
                    let pointRadius = radius * CGFloat(rating.value / 100.0)
                    let x = center.x + pointRadius * cos(angle)
                    let y = center.y + pointRadius * sin(angle)
                    
                    Circle()
                        .fill(Color.primaryRed)
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                }
                
                // Labels
                ForEach(Array(ratings.enumerated()), id: \.offset) { index, rating in
                    let angle = angleFor(index: index, total: count)
                    let labelRadius = radius + 20
                    let x = center.x + labelRadius * cos(angle)
                    let y = center.y + labelRadius * sin(angle)
                    
                    VStack(spacing: 1) {
                        Text(rating.name)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text(String(format: "%.0f", rating.value))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.primaryRed)
                    }
                    .position(x: x, y: y)
                }
            }
        }
    }
    
    private func angleFor(index: Int, total: Int) -> CGFloat {
        let baseAngle = -CGFloat.pi / 2
        return baseAngle + CGFloat(index) * (2 * .pi / CGFloat(total))
    }
}

// MARK: - Radar Grid Shape

struct RadarGridShape: Shape {
    let sides: Int
    let scale: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 * scale
        
        for i in 0..<sides {
            let angle = -CGFloat.pi / 2 + CGFloat(i) * (2 * .pi / CGFloat(sides))
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Radar Data Shape

struct RadarDataShape: Shape {
    let values: [Double]
    let sides: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        for i in 0..<sides {
            let angle = -CGFloat.pi / 2 + CGFloat(i) * (2 * .pi / CGFloat(sides))
            let value = i < values.count ? CGFloat(values[i]) : 0
            let point = CGPoint(
                x: center.x + radius * value * cos(angle),
                y: center.y + radius * value * sin(angle)
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        
        return path
    }
}
