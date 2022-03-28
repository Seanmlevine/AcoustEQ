//
//  SineSweepOsc.swift
//  AcoustEQ
//
//  Created by Sean Levine on 3/15/22.
//
import AudioKit
import AudioKitUI
import AudioToolbox
import SoundpipeAudioKit
import SwiftUI

struct SineSweepOscillatorData {
    var isPlaying: Bool = false
    var index: AUValue = 2.0
    var startfrequency: AUValue = 0.0
    var endfrequency: AUValue = 20000
    var duration: AUValue = 1

    var amplitude: AUValue = 0.1
    var rampDuration: AUValue = 0.01
}

class SineSweepOscillatorConductor: ObservableObject{

    let engine = AudioEngine()
//
//    func noteOn(note: MIDINoteNumber) {
//        data.isPlaying = true
//        data.frequency = note.midiNoteToFrequency()
//    }
//
//    func noteOff(note: MIDINoteNumber) {
//        data.isPlaying = false
//    }

    @Published var data = SineSweepOscillatorData() {
        didSet {
            if data.isPlaying {
                osc.start()
                osc.$index.ramp(to: data.index, duration: data.rampDuration)
//                osc.$frequency.ramp(to: data.startfrequency, duration: data.rampDuration)
                osc.$frequency.ramp(from: data.startfrequency, to: data.endfrequency, duration: data.duration)
                osc.$amplitude.ramp(to: data.amplitude, duration: data.rampDuration)
            } else {
                osc.amplitude = 0.0
            }
        }
    }

    var osc = MorphingOscillator()
    
    init() {
        engine.output = osc
    }

    func start() {
        osc.amplitude = 0.2
        do {
            try engine.start()
        } catch let err {
            Log(err)
        }
    }

    func stop() {
        data.isPlaying = false
        osc.stop()
        engine.stop()
    }
}

struct SineSweepOsc: View {
    @StateObject var conductor = SineSweepOscillatorConductor()

    var body: some View {
        VStack {
            Text(self.conductor.data.isPlaying ? "STOP" : "START").onTapGesture {
                self.conductor.data.isPlaying.toggle()
            }
            ParameterSlider(text: "Index",
                            parameter: self.$conductor.data.index,
                            range: 0 ... 3).padding(5)
            ParameterSlider(text: "Start Frequency",
                            parameter: self.$conductor.data.startfrequency,
                            range: 1...20000).padding(5)
            ParameterSlider(text: "End Frequency",
                            parameter: self.$conductor.data.endfrequency,
                            range: 1...20000).padding(5)
            ParameterSlider(text: "Amplitude",
                            parameter: self.$conductor.data.amplitude,
                            range: 0 ... 4).padding(5)
            ParameterSlider(text: "Ramp Duration",
                            parameter: self.$conductor.data.rampDuration,
                            range: 0...10).padding(5)

            NodeOutputView(conductor.osc)

        }
        .padding()
        .navigationBarTitle(Text("Sine Sweep Oscillator"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct SineSweepOsc_Previews: PreviewProvider {
    static var previews: some View {
        SineSweepOsc()
    }
}
