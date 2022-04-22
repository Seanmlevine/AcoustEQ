//
//  AVAudioPlayer.swift
//  AcoustEQ
//
//  Created by Sean Levine on 3/25/22.
//

import Foundation
import AVFoundation

var player: AVAudioPlayer?

func playSound(file: String) {
    
    guard let path = Bundle.main.path(forResource: file, ofType: "wav") else {
        return
    }
    let url = URL(fileURLWithPath: path)
    
    do {
        player = try AVAudioPlayer(contentsOf: url)
        player?.play()
    }
    catch let error {
        print(error.localizedDescription)
    }
}

func stopSound() {
    player?.stop()
    
}

func readURLIntoFloats(audioURL: URL) -> (signal: [Float], rate: Double, frameCount: Int) {

    let audioURL = AVAudioRecordingViewController.getWhistleURL()

    let file = try! AVAudioFile(forReading: audioURL)
    let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: 1, interleaved: false) ?? AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)

    let buf = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: UInt32(file.length))
    
    try! file.read(into: buf!)

    // this makes a copy, you might not want that
    let floatArray = Array(UnsafeBufferPointer(start: buf?.floatChannelData?[0], count:Int(buf!.frameLength)))
//        print(floatArray)
    
    return (signal: floatArray, rate: file.fileFormat.sampleRate, frameCount: Int(file.length))
    

}

