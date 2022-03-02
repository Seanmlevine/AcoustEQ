//
//  dBMetering.swift
//  AcoustEQ
//
//  Created by Sean Levine on 2/9/22.
//

import Foundation
import UIKit

class dBMeter: UIView {
    
    private var displayLink: CADisplayLink!
    //var dBValTimer = Timer()
    let dBVal = UILabel()
    
    
    @objc private func dBUpdate() {
//        dBMetering(inputBuffer: , bufferSize: <#T##Float#>)
//        dBVal.text = "\(Double(dBFS))"
//        if micOn {
//            self.dBMeter.text = "\(Double(self.spectrumView.dBFS))"
//        }
//        else {
//            dBValTimer.invalidate()
//        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        displayLink = CADisplayLink(target: self, selector: #selector(dBUpdate))
        displayLink.preferredFramesPerSecond = 60
        displayLink.add(to: .main, forMode: .common)
        displayLink.add(to: .main, forMode: .tracking)
//        dBValTimer.invalidate()
//        dBValTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(dBUpdate), userInfo: nil, repeats: true)
    }
    
    
    func dBMetering(inputBuffer: [Float], bufferSize: Float) {
//        fft.fftForward(inputBuffer)
//        let sumMag = fft.sumMagnitudes(lowFreq: 1, highFreq: 20000, useDB: false)
        // multiply by 2 to compensate for nyquist, averaged and converted to dB
        // divide buffer size by two because the size of the magnitudes array is the length of half the buffersize
//        dBFS = toDB( (sumMag * 2) / (bufferSize/2))
        // Find and hold the max value

    }
    
    private func toDB(_ inMagnitude: Float) -> Float {
        // ceil to 128db in order to avoid log10'ing 0
        let magnitude = max(inMagnitude, 0.000000000001)
        return 10 * log10f(magnitude)
    }

}
