import SwiftUI

struct MenuBarVisualizerView: View {
    @ObservedObject var audioParser: AudioParser
    
    let barCount = 6
    let maxHeight: CGFloat = 18
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<barCount, id: \.self) { index in
                let dataIndex = index * 3 + 2
                let magnitude = dataIndex < audioParser.magnitudes.count ? audioParser.magnitudes[dataIndex] : 0
                
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.primary)
                    .frame(width: 3, height: CGFloat(min(max(Double(magnitude) * Double(maxHeight), 2), Double(maxHeight))))
                    .animation(.easeInOut(duration: 0.1), value: magnitude)
            }
        }
        .frame(width: 40, height: 22)
        .contentShape(Rectangle())
    }
}
