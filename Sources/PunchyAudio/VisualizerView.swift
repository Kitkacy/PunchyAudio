import SwiftUI

struct VisualizerView: View {
    @ObservedObject var audioParser: AudioParser
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<audioParser.magnitudes.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.accentColor)
                    .frame(width: 4, height: CGFloat(min(max(Double(audioParser.magnitudes[index]) * 40, 4), 50)))
                    .animation(.easeInOut(duration: 0.1), value: audioParser.magnitudes[index])
            }
        }
        .frame(height: 60)
        .padding()
    }
}
