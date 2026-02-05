import SwiftUI

struct FullScreenVisualizerView: View {
    @ObservedObject var audioParser: AudioParser
    @State private var visualizationMode: VisualizationMode = .bars
    @State private var showControls: Bool = true
    @Environment(\.dismiss) var dismiss
    
    enum VisualizationMode: String, CaseIterable {
        case bars = "Bars"
        case wave = "Wave"
        case circles = "Circles"
        case mirror = "Mirror"
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            switch visualizationMode {
            case .bars:
                BarsVisualization(magnitudes: audioParser.magnitudes)
            case .wave:
                WaveVisualization(magnitudes: audioParser.magnitudes)
            case .circles:
                CirclesVisualization(magnitudes: audioParser.magnitudes)
            case .mirror:
                MirrorVisualization(magnitudes: audioParser.magnitudes)
            }
            
            VStack {
                HStack {
                    if showControls {
                        HStack(spacing: 12) {
                            ForEach(VisualizationMode.allCases, id: \.self) { mode in
                                Button(action: { visualizationMode = mode }) {
                                    Text(mode.rawValue)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(visualizationMode == mode ? .white : .gray)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(visualizationMode == mode ? Color.white.opacity(0.2) : Color.clear)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
                        .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showControls.toggle()
                        }
                    }) {
                        Image(systemName: showControls ? "chevron.left.circle.fill" : "chevron.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray.opacity(0.8))
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                Spacer()
            }
        }
    }
}

func spectrumColor(for index: Int, total: Int, brightness: Float = 1.0) -> Color {
    let hue = Double(index) / Double(max(total, 1))
    return Color(hue: hue, saturation: 1.0, brightness: Double(max(brightness, 0.5)))
}

func gradientForBar(index: Int, total: Int) -> LinearGradient {
    let hue1 = Double(index) / Double(max(total, 1))
    let hue2 = min(hue1 + 0.08, 1.0)
    return LinearGradient(
        colors: [
            Color(hue: hue1, saturation: 0.9, brightness: 1.0),
            Color(hue: hue2, saturation: 0.7, brightness: 0.8)
        ],
        startPoint: .bottom,
        endPoint: .top
    )
}

struct BarsVisualization: View {
    let magnitudes: [Float]
    
    var body: some View {
        GeometryReader { geo in
            let horizontalPadding: CGFloat = 24
            let bottomPadding: CGFloat = 40
            let availableWidth = geo.size.width - horizontalPadding * 2
            let barCount = magnitudes.count
            let spacing: CGFloat = 3
            let barWidth = max((availableWidth - CGFloat(barCount - 1) * spacing) / CGFloat(max(barCount, 1)), 2)
            let availableHeight = geo.size.height - bottomPadding
            
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(0..<barCount, id: \.self) { index in
                    let magnitude = magnitudes[index]
                    let barHeight = CGFloat(magnitude) * availableHeight * 0.9
                    
                    RoundedRectangle(cornerRadius: barWidth / 3)
                        .fill(gradientForBar(index: index, total: barCount))
                        .frame(width: barWidth, height: max(barHeight, 2))
                        .shadow(color: spectrumColor(for: index, total: barCount).opacity(0.6), radius: 8, y: 0)
                        .animation(.easeOut(duration: 0.08), value: magnitude)
                }
            }
            .frame(width: availableWidth, height: availableHeight, alignment: .bottom)
            .position(x: geo.size.width / 2, y: (geo.size.height - bottomPadding) / 2)
        }
    }
}

struct WaveVisualization: View {
    let magnitudes: [Float]
    
    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { layer in
                WavePath(magnitudes: magnitudes, layer: layer)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hue: Double(layer) * 0.3, saturation: 0.8, brightness: 1.0),
                                Color(hue: Double(layer) * 0.3 + 0.15, saturation: 0.9, brightness: 0.9),
                                Color(hue: Double(layer) * 0.3 + 0.3, saturation: 0.7, brightness: 1.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: CGFloat(4 - layer)
                    )
                    .shadow(color: Color(hue: Double(layer) * 0.3, saturation: 1, brightness: 1).opacity(0.5), radius: 10)
                    .opacity(Double(3 - layer) / 3.0)
            }
        }
    }
}

struct WavePath: Shape {
    let magnitudes: [Float]
    let layer: Int
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let count = magnitudes.count
        if count < 2 { return path }
        
        let midY = rect.midY
        let stepX = rect.width / CGFloat(count - 1)
        let amplitude = rect.height * 0.35 * CGFloat(1.0 - Float(layer) * 0.2)
        
        path.move(to: CGPoint(x: rect.minX, y: midY))
        
        for i in 0..<count {
            let x = rect.minX + CGFloat(i) * stepX
            let y = midY - CGFloat(magnitudes[i]) * amplitude + CGFloat(layer) * 10
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                let prevX = rect.minX + CGFloat(i - 1) * stepX
                let prevY = midY - CGFloat(magnitudes[i - 1]) * amplitude + CGFloat(layer) * 10
                let controlX1 = prevX + stepX / 2
                let controlX2 = x - stepX / 2
                path.addCurve(to: CGPoint(x: x, y: y),
                             control1: CGPoint(x: controlX1, y: prevY),
                             control2: CGPoint(x: controlX2, y: y))
            }
        }
        
        return path
    }
}

struct CirclesVisualization: View {
    let magnitudes: [Float]
    
    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let maxRadius = min(geo.size.width, geo.size.height) * 0.4
            let count = magnitudes.count
            
            ZStack {
                ForEach(0..<min(count, 15), id: \.self) { index in
                    let magnitude = index < magnitudes.count ? magnitudes[index * 2] : Float(0)
                    let baseRadius = maxRadius * CGFloat(index + 1) / 15.0
                    let dynamicRadius = baseRadius + CGFloat(magnitude) * 60
                    let ringHue = Double(index) / 15.0
                    
                    Circle()
                        .stroke(
                            Color(hue: ringHue, saturation: 1.0, brightness: Double(max(magnitude, 0.6))),
                            lineWidth: 2.5 + CGFloat(magnitude) * 5
                        )
                        .frame(width: dynamicRadius * 2, height: dynamicRadius * 2)
                        .position(center)
                        .shadow(color: Color(hue: ringHue, saturation: 1.0, brightness: 1.0).opacity(Double(magnitude) * 1.0), radius: 20)
                        .animation(.easeOut(duration: 0.1), value: magnitude)
                }
                
                ForEach(0..<count, id: \.self) { index in
                    let magnitude = magnitudes[index]
                    let angle = Angle(degrees: Double(index) / Double(count) * 360 - 90)
                    let barLength = CGFloat(magnitude) * maxRadius * 0.6
                    let innerRadius: CGFloat = maxRadius * 0.15
                    
                    let startPoint = CGPoint(
                        x: center.x + innerRadius * CGFloat(cos(angle.radians)),
                        y: center.y + innerRadius * CGFloat(sin(angle.radians))
                    )
                    let endPoint = CGPoint(
                        x: center.x + (innerRadius + barLength) * CGFloat(cos(angle.radians)),
                        y: center.y + (innerRadius + barLength) * CGFloat(sin(angle.radians))
                    )
                    
                    Path { path in
                        path.move(to: startPoint)
                        path.addLine(to: endPoint)
                    }
                    .stroke(
                        Color(hue: Double(index) / Double(max(count, 1)), saturation: 1.0, brightness: Double(max(magnitude, 0.7))),
                        lineWidth: 3.5
                    )
                    .shadow(color: Color(hue: Double(index) / Double(max(count, 1)), saturation: 1.0, brightness: 1.0).opacity(0.7), radius: 8)
                    .animation(.easeOut(duration: 0.08), value: magnitude)
                }
            }
        }
        .padding(40)
    }
}

struct MirrorVisualization: View {
    let magnitudes: [Float]
    
    var body: some View {
        GeometryReader { geo in
            let horizontalPadding: CGFloat = 24
            let availableWidth = geo.size.width - horizontalPadding * 2
            let barCount = magnitudes.count
            let spacing: CGFloat = 2
            let barWidth = max((availableWidth - CGFloat(barCount - 1) * spacing) / CGFloat(max(barCount, 1)), 2)
            let halfHeight = geo.size.height / 2 * 0.85
            
            VStack(spacing: 0) {
                Spacer()
                
                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(0..<barCount, id: \.self) { index in
                        let magnitude = magnitudes[index]
                        let barHeight = CGFloat(magnitude) * halfHeight
                        
                        RoundedRectangle(cornerRadius: barWidth / 3)
                            .fill(gradientForBar(index: index, total: barCount))
                            .frame(width: barWidth, height: max(barHeight, 1))
                            .shadow(color: spectrumColor(for: index, total: barCount).opacity(0.4), radius: 6)
                            .animation(.easeOut(duration: 0.08), value: magnitude)
                    }
                }
                .frame(width: availableWidth)
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.3), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: availableWidth, height: 1)
                
                HStack(alignment: .top, spacing: spacing) {
                    ForEach(0..<barCount, id: \.self) { index in
                        let magnitude = magnitudes[index]
                        let barHeight = CGFloat(magnitude) * halfHeight
                        
                        RoundedRectangle(cornerRadius: barWidth / 3)
                            .fill(gradientForBar(index: index, total: barCount))
                            .frame(width: barWidth, height: max(barHeight, 1))
                            .shadow(color: spectrumColor(for: index, total: barCount).opacity(0.3), radius: 6)
                            .animation(.easeOut(duration: 0.08), value: magnitude)
                            .opacity(0.6)
                    }
                }
                .frame(width: availableWidth)
                
                Spacer()
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}
