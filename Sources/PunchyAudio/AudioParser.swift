import Foundation
import ScreenCaptureKit
import AVFoundation
import Accelerate

class AudioParser: NSObject, ObservableObject, SCStreamOutput, SCStreamDelegate, @unchecked Sendable {
    private var stream: SCStream?
    private var maxMagnitude: Float = 0.001
    private var previousMagnitudes: [Float] = []
    
    @Published var magnitudes: [Float] = []
    @Published var isCapturing: Bool = false
    
    override init() {
        super.init()
        startSystemAudioCapture()
    }
    
    func startSystemAudioCapture() {
        Task {
            do {
                let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                guard let display = content.displays.first else {
                    print("No display found")
                    return
                }
                
                let excludedApps = content.applications.filter {
                    $0.bundleIdentifier == Bundle.main.bundleIdentifier
                }
                
                let filter = SCContentFilter(
                    display: display,
                    excludingApplications: excludedApps,
                    exceptingWindows: []
                )
                
                let config = SCStreamConfiguration()
                config.capturesAudio = true
                config.sampleRate = 44100
                config.channelCount = 2
                config.width = 2
                config.height = 2
                config.minimumFrameInterval = CMTime(value: 1, timescale: 1)
                config.queueDepth = 5
                
                stream = SCStream(filter: filter, configuration: config, delegate: self)
                try stream?.addStreamOutput(self, type: .audio, sampleHandlerQueue: DispatchQueue.global(qos: .userInteractive))
                
                try await stream?.startCapture()
                print("System audio capture started")
                DispatchQueue.main.async {
                    self.isCapturing = true
                }
            } catch {
                print("Failed to start capture: \(error)")
                DispatchQueue.main.async {
                    self.isCapturing = false
                }
                if let scError = error as? SCStreamError, scError.code == .userDeclined {
                    DispatchQueue.main.async {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                }
            }
        }
    }
    
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .audio else { return }
        processAudio(sampleBuffer: sampleBuffer)
    }
    
    func stream(_ stream: SCStream, didStopWithError error: Error) {
        print("Stream stopped: \(error)")
        DispatchQueue.main.async {
            self.isCapturing = false
        }
    }
    
    private func processAudio(sampleBuffer: CMSampleBuffer) {
        guard let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) else { return }
        
        var lengthAtOffsetOut: Int = 0
        var totalLengthOut: Int = 0
        var dataPointerOut: UnsafeMutablePointer<Int8>?
        
        let status = CMBlockBufferGetDataPointer(
            blockBuffer, atOffset: 0,
            lengthAtOffsetOut: &lengthAtOffsetOut,
            totalLengthOut: &totalLengthOut,
            dataPointerOut: &dataPointerOut
        )
        guard status == kCMBlockBufferNoErr, let dataPointer = dataPointerOut else { return }
        
        let sampleCount = totalLengthOut / MemoryLayout<Float>.size / 2
        let frameLength = min(sampleCount, 1024)
        if frameLength == 0 { return }
        
        let floatPointer = dataPointer.withMemoryRebound(to: Float.self, capacity: sampleCount * 2) { $0 }
        
        var real = [Float](repeating: 0, count: frameLength)
        let inputBuffer = UnsafeBufferPointer(start: floatPointer, count: sampleCount * 2)
        vDSP_vadd(inputBuffer.baseAddress!, 2, inputBuffer.baseAddress!.advanced(by: 1), 2, &real, 1, vDSP_Length(frameLength))
        var divisor: Float = 2.0
        vDSP_vsdiv(real, 1, &divisor, &real, 1, vDSP_Length(frameLength))
        
        var imaginary = [Float](repeating: 0, count: frameLength)
        let log2n = vDSP_Length(log2(Float(frameLength)))
        guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else { return }
        
        var mags = [Float](repeating: 0.0, count: frameLength / 2)
        
        real.withUnsafeMutableBufferPointer { realPtr in
            imaginary.withUnsafeMutableBufferPointer { imagPtr in
                guard let realAddr = realPtr.baseAddress, let imagAddr = imagPtr.baseAddress else { return }
                var splitComplex = DSPSplitComplex(realp: realAddr, imagp: imagAddr)
                vDSP_fft_zip(fftSetup, &splitComplex, 1, log2n, FFTDirection(kFFTDirection_Forward))
                vDSP_zvmags(&splitComplex, 1, &mags, 1, vDSP_Length(frameLength / 2))
            }
        }
        
        var sqrtMags = [Float](repeating: 0.0, count: frameLength / 2)
        var halfLen = Int32(frameLength / 2)
        vvsqrtf(&sqrtMags, mags, &halfLen)
        
        vDSP_destroy_fftsetup(fftSetup)
        
        let barCount = 30
        let chunkSize = max((frameLength / 2) / barCount, 1)
        var rawBars: [Float] = []
        
        for i in 0..<barCount {
            let start = i * chunkSize
            let end = min(start + chunkSize, sqrtMags.count)
            if start < sqrtMags.count {
                rawBars.append(sqrtMags[start..<end].max() ?? 0)
            }
        }
        
        let currentPeak = rawBars.max() ?? 0
        if currentPeak > maxMagnitude {
            maxMagnitude = currentPeak
        } else {
            maxMagnitude = maxMagnitude * 0.998
        }
        maxMagnitude = max(maxMagnitude, 0.0001)
        
        var newMagnitudes: [Float] = rawBars.map { bar in
            let normalized = bar / maxMagnitude
            return min(pow(normalized, 0.35), 1.0)
        }
        
        if previousMagnitudes.count == newMagnitudes.count {
            for i in 0..<newMagnitudes.count {
                newMagnitudes[i] = newMagnitudes[i] * 0.6 + previousMagnitudes[i] * 0.4
            }
        }
        previousMagnitudes = newMagnitudes
        
        DispatchQueue.main.async {
            self.magnitudes = newMagnitudes
        }
    }
}
