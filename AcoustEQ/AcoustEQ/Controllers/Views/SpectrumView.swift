

import UIKit
import Accelerate

class SpectrumView: UIView {

    private var needsNewFFT: Bool = false

    var shouldDrawFrequencyLines: Bool = false

    private let bgColor = UIColor(hex: "262629")
    private let spectrumBgColor = UIColor(white: 0.2, alpha: 1)
    private let spectrumLineColor = UIColor.white
    private let lineWidth: CGFloat = 1
    private let lineSpacing: CGFloat = 3

    private var displayLink: CADisplayLink!

    // append user defaults when opened
    public var fft: TempiFFT = TempiFFT(withSize: 2048, sampleRate: Float(44100.0))
    public var dBFS: Float = 0.0
    
    // Save user settings if the stopped fft is what you want
    // Output fftSamples to chart when done recording
    private var fftSamples: [Float] = []

    private var shapeLayer: CAShapeLayer!

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        backgroundColor = bgColor
        layer.cornerRadius = 8
        layer.cornerCurve = .continuous
        layer.masksToBounds = true
        isOpaque = true

        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.preferredFramesPerSecond = 60
        displayLink.add(to: .main, forMode: .common)
        displayLink.add(to: .main, forMode: .tracking)
        
        // Change with settings
        fft.windowType = .hanning

        shapeLayer = CAShapeLayer()
        shapeLayer.frame = bounds
        layer.addSublayer(shapeLayer)
    }

    @objc private func update() {


        let points: [CGPoint] = fftSamples.enumerated().map { i, samp in
            let x = bounds.width * CGFloat(i) / CGFloat(fftSamples.count)
            let height = CGFloat(samp) * bounds.height
//            print(samp)
//            print(height)
            //bounds.height = 646
            //for inverse, do CGFloat(1-samp)
            return CGPoint(x: x, y: bounds.height - height)
        }

        let path = UIBezierPath()
        var lastPoint = CGPoint(x: -20, y: bounds.height*2)
        path.move(to: lastPoint)
        for point in points {
            if point.y == lastPoint.y {
                continue
            }
            let midPoint = midPoint(forPoints: lastPoint, point)
            path.addQuadCurve(to: midPoint, controlPoint: controlPointForPoints(midPoint, lastPoint))
            path.addQuadCurve(to: point, controlPoint: controlPointForPoints(midPoint, point))
            lastPoint = point
        }
        path.addLine(to: CGPoint(x: bounds.width+20, y: bounds.height*2))
        path.close()

        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = spectrumLineColor.cgColor
        shapeLayer.fillColor = spectrumBgColor.cgColor
        shapeLayer.frame = bounds
        
        
        
    }

    private func midPoint(forPoints p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }

    private func controlPointForPoints(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        var controlPoint = midPoint(forPoints: p1, p2)
        let diffY = abs(p2.y - controlPoint.y)

        if p1.y < p2.y {
            controlPoint.y += diffY
        } else if p1.y > p2.y {
            controlPoint.y -= diffY
        }

        return controlPoint
    }

    func performFFT(inputBuffer: [Float], bufferSize: Float, bandsPerOctave: Int, scale: String) {
        needsNewFFT = false
        
        // Perform the FFT
        fft.fftForward(inputBuffer)
        
        // Map FFT data to logical bands. This gives 4 bands per octave across 7 octaves = 28 bands.
        if scale == "Logarithm" {
            fft.calculateLogarithmicBands(minFrequency: 50, maxFrequency: 20000, bandsPerOctave: bandsPerOctave)
        }
        else if scale == "Linear"{
            fft.calculateLinearBands(minFrequency: 50, maxFrequency: 20000, numberOfBands: bandsPerOctave)
        }
        
        let maxDB: Float = 180
        // look up best practice for dBRef value!
        let dbRef: Float = 0.000002
        var fftArray: [Float] = []

        for i in 0..<fft.numberOfBands {
            let mag = fft.magnitudeAtBand(i) * 2 / bufferSize //Change value here for buffer size (compensate for positive and negative frequency values)
            
            // dBX shows graph values from 120 to -80
            let db = ((20 * log10f(mag / dbRef)) / maxDB).clamped(to: -80...120)
            
            fftArray.append(db)
            
            // vector addition for weightings look at site shared by Nat (for loop or use accelerate)
            // create new weighting curves depending on FFT size
        }
        
        dBMetering(inputBuffer: inputBuffer, bufferSize: bufferSize)

        if fftSamples.isEmpty {
            fftSamples = fftArray
            return
        }
        if fftSamples != fftArray {
            fftSamples = fftArray
            return
        }

        for i in 0..<fftSamples.count {
            fftSamples[i] = (fftSamples[i] * 0.5) + (fftArray[i] * 0.5)
        }
        
    }
    func dBMetering(inputBuffer: [Float], bufferSize: Float) {
        // let maxDB: Float = 180
        // look up best practice for dBRef value!
        // let dbRef: Float = 0.00001
        let sumMag = self.fft.sumMagnitudes(lowFreq: 1, highFreq: 20000, useDB: false)
        
        // multiply by 2 to compensate for nyquist, averaged and converted to dB
        
        // divide buffer size by two because the size of the magnitudes array is the length of half the buffersize
        self.dBFS = toDB( (sumMag * 2) / (bufferSize/2)) + 70
        // Find and hold the max value

    }
    
    private func toDB(_ inMagnitude: Float) -> Float {
        // ceil to 128db in order to avoid log10'ing 0
        let magnitude = max(inMagnitude, 0.000000000001)
        return 10 * log10f(magnitude)
    }


}
