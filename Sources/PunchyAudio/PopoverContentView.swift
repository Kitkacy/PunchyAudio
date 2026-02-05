import SwiftUI

struct PopoverContentView: View {
    @ObservedObject var audioParser: AudioParser
    var onOpenVisualizer: () -> Void
    var onQuit: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("PunchyAudio")
                .font(.headline)
            
            Divider()
            
            Button(action: onOpenVisualizer) {
                HStack {
                    Image(systemName: "sparkles.rectangle.stack")
                    Text("Open Visualizer")
                }
                .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
            
            Divider()
            
            HStack(spacing: 6) {
                Circle()
                    .fill(audioParser.isCapturing ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                Text(audioParser.isCapturing ? "Capturing system audio" : "Not capturing")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            Link(destination: URL(string: "https://github.com/Kitkacy")!) {
                HStack(spacing: 6) {
                    GitHubIcon()
                        .fill(Color.secondary)
                        .frame(width: 14, height: 14)
                    Text("Author: @Kitkacy")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Divider()
            
            Button("Quit") {
                onQuit()
            }
            .keyboardShortcut("q")
        }
        .padding()
        .frame(width: 220)
    }
}

struct GitHubIcon: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 16.0
        let sy = rect.height / 16.0
        var p = Path()
        p.move(to: CGPoint(x: 8*sx, y: 0))
        p.addCurve(to: CGPoint(x: 0, y: 8*sy),
                   control1: CGPoint(x: 3.58*sx, y: 0),
                   control2: CGPoint(x: 0, y: 3.58*sy))
        p.addCurve(to: CGPoint(x: 5.47*sx, y: 15.9*sy),
                   control1: CGPoint(x: 0, y: 11.54*sy),
                   control2: CGPoint(x: 2.29*sx, y: 14.73*sy))
        p.addCurve(to: CGPoint(x: 6*sx, y: 14.69*sy),
                   control1: CGPoint(x: 5.9*sx, y: 15.98*sy),
                   control2: CGPoint(x: 6*sx, y: 15.37*sy))
        p.addLine(to: CGPoint(x: 6*sx, y: 13.13*sy))
        p.addCurve(to: CGPoint(x: 2.34*sx, y: 11.67*sy),
                   control1: CGPoint(x: 3.73*sx, y: 13.6*sy),
                   control2: CGPoint(x: 2.34*sx, y: 13.14*sy))
        p.addCurve(to: CGPoint(x: 3.2*sx, y: 9.94*sy),
                   control1: CGPoint(x: 2.34*sx, y: 11.04*sy),
                   control2: CGPoint(x: 2.65*sx, y: 10.45*sy))
        p.addCurve(to: CGPoint(x: 3.03*sx, y: 7.97*sy),
                   control1: CGPoint(x: 2.73*sx, y: 9.5*sy),
                   control2: CGPoint(x: 2.68*sx, y: 8.63*sy))
        p.addCurve(to: CGPoint(x: 5.44*sx, y: 8.35*sy),
                   control1: CGPoint(x: 3.68*sx, y: 6.63*sy),
                   control2: CGPoint(x: 5.44*sx, y: 6.94*sy))
        p.addLine(to: CGPoint(x: 5.44*sx, y: 9.49*sy))
        p.addCurve(to: CGPoint(x: 6.37*sx, y: 10.4*sy),
                   control1: CGPoint(x: 5.44*sx, y: 9.99*sy),
                   control2: CGPoint(x: 5.85*sx, y: 10.4*sy))
        p.addLine(to: CGPoint(x: 9.63*sx, y: 10.4*sy))
        p.addCurve(to: CGPoint(x: 10.56*sx, y: 9.49*sy),
                   control1: CGPoint(x: 10.15*sx, y: 10.4*sy),
                   control2: CGPoint(x: 10.56*sx, y: 9.99*sy))
        p.addLine(to: CGPoint(x: 10.56*sx, y: 8.35*sy))
        p.addCurve(to: CGPoint(x: 12.97*sx, y: 7.97*sy),
                   control1: CGPoint(x: 10.56*sx, y: 6.94*sy),
                   control2: CGPoint(x: 12.32*sx, y: 6.63*sy))
        p.addCurve(to: CGPoint(x: 12.8*sx, y: 9.94*sy),
                   control1: CGPoint(x: 13.32*sx, y: 8.63*sy),
                   control2: CGPoint(x: 13.27*sx, y: 9.5*sy))
        p.addCurve(to: CGPoint(x: 13.66*sx, y: 11.67*sy),
                   control1: CGPoint(x: 13.35*sx, y: 10.45*sy),
                   control2: CGPoint(x: 13.66*sx, y: 11.04*sy))
        p.addCurve(to: CGPoint(x: 10*sx, y: 13.13*sy),
                   control1: CGPoint(x: 13.66*sx, y: 13.14*sy),
                   control2: CGPoint(x: 12.27*sx, y: 13.6*sy))
        p.addLine(to: CGPoint(x: 10*sx, y: 14.69*sy))
        p.addCurve(to: CGPoint(x: 10.53*sx, y: 15.9*sy),
                   control1: CGPoint(x: 10*sx, y: 15.37*sy),
                   control2: CGPoint(x: 10.1*sx, y: 15.98*sy))
        p.addCurve(to: CGPoint(x: 16*sx, y: 8*sy),
                   control1: CGPoint(x: 13.71*sx, y: 14.73*sy),
                   control2: CGPoint(x: 16*sx, y: 11.54*sy))
        p.addCurve(to: CGPoint(x: 8*sx, y: 0),
                   control1: CGPoint(x: 16*sx, y: 3.58*sy),
                   control2: CGPoint(x: 12.42*sx, y: 0))
        p.closeSubpath()
        return p
    }
}