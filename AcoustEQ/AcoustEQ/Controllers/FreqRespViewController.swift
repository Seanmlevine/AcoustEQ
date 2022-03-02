//  FreqRespViewController.swift
//  AcoustEQ
//
//  Created by Sean Levine on 11/8/21.
//
import UIKit
import AVFoundation

class FreqRespViewController: UIViewController, setFreqResponseDelegate {

    
    // Storyboard Init

    @IBOutlet weak var spectrumView: SpectrumView!
    @IBOutlet weak var countdownTimer: UILabel!
    @IBOutlet weak var RecordButton: UIButton!
    @IBOutlet weak var closeRecording: UIButton!
    @IBOutlet weak var dBMeter: UILabel!
    
    // Init Audio control
    public var audioInput: TempiAudioInput!
    
    // Init Timer
    var count = 5
    var recTimer = Timer()
    
    // Init dB Update Timer
    var dBValTimer = Timer()
    private var displayLink: CADisplayLink!
    
    //Init Audio Settings
    //TODO: change init values to UserDefaults
    var sampleRate = 44100.0
    var recordingBuffer = 16384.0 //samples
    var regularBuffer = 2048.0
    var octaveBands = 8
    var scale = "Logarithm"
    private var micOn: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countdownTimer?.isHidden = true
        closeRecording?.isHidden = true
        
        startAudio()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.audioInput.startRecording()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.audioInput.stopRecording()
        self.micOn = false
    }
    
    //TODO: Play-Pause Button
    
    
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        
        //Stop Recording
        audioInput.stopRecording()
        self.micOn = false
        
        //Start Timer
        startRecTimer()
        
        //Countdown
        countdownTimer.text = "Recording in... " + String(count)
        countdownTimer.isHidden = false
        
        //Recording buffer length initialized
        
        //Wait for countdown to finish
        let totalWaitTime =  DispatchTimeInterval.seconds(count)
        DispatchQueue.main.asyncAfter(deadline: .now() + totalWaitTime) {

            let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
                // somehow change the numberOfFrames in callback and spectrumView
                tempi_dispatch_main { () -> () in
                    //self.spectrumView.fft = TempiFFT(withSize: recordingBuffer, sampleRate: sampleRate)
                    self.spectrumView.performFFT(inputBuffer: samples, bufferSize: Float(2048.0), bandsPerOctave: self.octaveBands, scale: self.scale)
                }
                
            }
            self.audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: 44100, numberOfChannels: 1, bufferSize: Float(self.recordingBuffer))
            
            
            self.audioInput.startRecording() //record and stop recording after certain period of time
            
            //Record for length of buffer and stop recording
            let totalRecordTime =  DispatchTimeInterval.seconds(Int(self.recordingBuffer/self.sampleRate))
            DispatchQueue.main.asyncAfter(deadline: .now() + totalRecordTime) { //change this value depending on the buffer size
                self.audioInput.stopRecording()
                self.micOn = false
                self.closeRecording.isHidden = false
            }
            
        }
    }
    
    @IBAction func closeRecordingTapped(_ sender: UIButton) {
        self.closeRecording.isHidden = true
        startAudio()
    }
    
    func setFreqResponse(frameSize: Int, octaveBand: Int, scale: String) {
        //audioInput.stopRecording()
        self.regularBuffer = Double(frameSize)
        self.octaveBands = octaveBand
        self.scale = scale
        startAudio()
    }
    
    func startAudio() {
        self.dBMeteringOn()
        self.spectrumView.fft = TempiFFT(withSize: Int(self.regularBuffer), sampleRate: Float(self.sampleRate))
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
            
//            DispatchQueue.global().async {
//                self.dBMeteringOn()
                
            tempi_dispatch_main { () -> () in
                self.spectrumView.performFFT(inputBuffer: samples, bufferSize: Float(self.regularBuffer), bandsPerOctave: self.octaveBands, scale: self.scale)
            }
//            }
            
        }
        
        self.audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: 44100, numberOfChannels: 1, bufferSize: Float(self.regularBuffer))
        self.audioInput.startRecording()
        self.micOn = true
        //TODO: Change the dBMeter text to the value continuously
        //TODO: look up how to do Dispatch_async (what is @escaping)
        //TODO: Use a timer to change the value of the meter (tab saved)

    }
    
    //TODO: SEPERATE TIMER from this swift page
    //Countdown selector used to change the timer
    @objc func updateCounter() {
        if(count > 0) {
            count -= 1
            countdownTimer.text = "Recording in... " + String(count)
        }
        else {
            countdownTimer.isHidden = true
            recTimer.invalidate()
            count = 5
        }
    }
    
    func startRecTimer() {
        recTimer.invalidate()
        recTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    //TODO: dBMeter
    
    @objc func dBUpdate() {
        let dbfs = self.spectrumView.dBFS
        if micOn {
            self.dBMeter.text = "\(dbfs)"
        }
        else {
            dBValTimer.invalidate()
        }
    }
    
    func dBMeteringOn() {
        //TODO: look at how PKC changes the decibel value
        
//        dBValTimer.invalidate()
        dBValTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(dBUpdate), userInfo: nil, repeats: true)
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getSettingsSegue"{
            let settings: SettingsViewController = segue.destination as! SettingsViewController
            settings.delegate = self
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        NSLog("*** Memory!")
        super.didReceiveMemoryWarning()
    }


}
