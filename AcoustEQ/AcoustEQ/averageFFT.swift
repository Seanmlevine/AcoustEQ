//
//  averageFFT.swift
//  
//
//  Created by Sean Levine on 3/27/22.
//

import Foundation

private var needsNewFFT: Bool = false

var averageFFT: TempiFFT = TempiFFT(withSize: 2048, sampleRate: Float(44100.0))

private var fftSamples: [Float] = []


func performAverageFFT(inputBuffer: [Float], bufferSize: Float, bandsPerOctave: Int, scale: String) {
    needsNewFFT = false
    
    // Perform the FFT
    averageFFT.fftForward(inputBuffer)
    
    // Map FFT data to logical bands. This gives 4 bands per octave across 7 octaves = 28 bands.
    if scale == "Logarithm" {
        averageFFT.calculateLogarithmicBands(minFrequency: 50, maxFrequency: 20000, bandsPerOctave: bandsPerOctave)
    }
    else if scale == "Linear"{
        averageFFT.calculateLinearBands(minFrequency: 50, maxFrequency: 20000, numberOfBands: bandsPerOctave)
    }
    
    let maxDB: Float = 180
    // look up best practice for dBRef value!
    let dbRef: Float = 0.000002
    var fftArray: [Float] = []

    for i in 0..<averageFFT.numberOfBands {
        let mag = averageFFT.magnitudeAtBand(i) * 2 / bufferSize //Change value here for buffer size (compensate for positive and negative frequency values)
        
        // dBX shows graph values from 120 to -80
        let db = ((20 * log10f(mag / dbRef)) / maxDB).clamped(to: -80...120)
        
        fftArray.append(db)
        
        // vector addition for weightings look at site shared by Nat (for loop or use accelerate)
        // create new weighting curves depending on FFT size
    }

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
