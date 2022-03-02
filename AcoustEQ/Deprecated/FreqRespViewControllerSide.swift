//
//  FreqRespViewController.swift
//  AcoustEQ
//
//  Created by Sean Levine on 11/8/21.
//
import SideMenu
import UIKit
import AVFoundation

class FreqRespEditViewController: UIViewController {


    // Storyboard Init
    let spectrumView = SpectrumView()
    let recordButtonProg = UIButton()
    // For storyboard version
//    @IBOutlet weak var spectrumView: SpectrumView!
    @IBOutlet weak var countdownTimer: UILabel!
    @IBOutlet weak var RecordButton: UIButton!
    @IBOutlet weak var closeRecording: UIButton!
    
    // Init Audio control
    var audioInput: TempiAudioInput!
    
    // Init Timer
    var count = 5
    var timer = Timer()
    
    //Init Audio Settings
    var sampleRate = 44100.0
    var recordingBuffer = 16384.0 //samples
    var regularBuffer = 2048.0
    var octaveBands = 8
    var scale = "Logarithmic"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Configure SpectrumView
        view.addSubview(spectrumView)
        spectrumView.frame = view.bounds
        
        
        recordButtonProg.setTitle("record", for: .normal)
        recordButtonProg.frame = CGRect(x:0, y:50, width: 90, height: 30)
        recordButtonProg.setTitleColor(.red, for: .normal)
        recordButtonProg.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        
        
        
        
        
        countdownTimer?.isHidden = true
        closeRecording?.isHidden = true

        
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
//            self.gotSomeAudio(timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
            tempi_dispatch_main { () -> () in
                self.spectrumView.performFFT(inputBuffer: samples, bufferSize: Float(self.regularBuffer), bandsPerOctave: self.octaveBands, scale: self.scale)
//                self.spectrumView?.performFFT(inputBuffer: samples, bufferSize: Float(self.regularBuffer))
            }
            
        }
        
        audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: 44100, numberOfChannels: 1)
        audioInput.startRecording()
    }
    

    @objc func recordButtonTapped(_ sender: UIButton) {
        
        //Stop Recording
        audioInput.stopRecording()
        
        //Start Timer
        startTimer()
        
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
            self.audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: 44100, numberOfChannels: 1)
            
            // Change the IO Buffer duration
            do {
                
            try self.audioInput.audioSession.setPreferredIOBufferDuration(self.recordingBuffer/self.sampleRate)
                
            } catch{
                print("*** audioSession error: \(error)")
            }
            
            self.audioInput.startRecording() //record and stop recording after certain period of time
            
            //Record for length of buffer and stop recording
            let totalRecordTime =  DispatchTimeInterval.seconds(Int(self.recordingBuffer/self.sampleRate))
            DispatchQueue.main.asyncAfter(deadline: .now() + totalRecordTime) { //change this value depending on the buffer size
                self.audioInput.stopRecording()
                self.closeRecording.isHidden = false
            }
            
        }
    }
//    @IBAction func recordButtonTapped(_ sender: UIButton) {
//
//        //Stop Recording
//        audioInput.stopRecording()
//
//        //Start Timer
//        startTimer()
//
//        //Countdown
//        countdownTimer.text = "Recording in... " + String(count)
//        countdownTimer.isHidden = false
//
//        //Recording buffer length initialized
//
//        //Wait for countdown to finish
//        let totalWaitTime =  DispatchTimeInterval.seconds(count)
//        DispatchQueue.main.asyncAfter(deadline: .now() + totalWaitTime) {
//
//            let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
//                // somehow change the numberOfFrames in callback and spectrumView
//                tempi_dispatch_main { () -> () in
//                    //self.spectrumView.fft = TempiFFT(withSize: recordingBuffer, sampleRate: sampleRate)
//                    self.spectrumView.performFFT(inputBuffer: samples, bufferSize: Float(2048.0))
//                }
//
//            }
//            self.audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: 44100, numberOfChannels: 1)
//
//            // Change the IO Buffer duration
//            do {
//
//            try self.audioInput.audioSession.setPreferredIOBufferDuration(self.recordingBuffer/self.sampleRate)
//
//            } catch{
//                print("*** audioSession error: \(error)")
//            }
//
//            self.audioInput.startRecording() //record and stop recording after certain period of time
//
//            //Record for length of buffer and stop recording
//            let totalRecordTime =  DispatchTimeInterval.seconds(Int(self.recordingBuffer/self.sampleRate))
//            DispatchQueue.main.asyncAfter(deadline: .now() + totalRecordTime) { //change this value depending on the buffer size
//                self.audioInput.stopRecording()
//                self.closeRecording.isHidden = false
//            }
//
//        }
//    }
    
    @IBAction func closeRecordingTapped(_ sender: UIButton) {
        self.closeRecording.isHidden = true
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
//            self.gotSomeAudio(timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
            tempi_dispatch_main { () -> () in
                self.spectrumView.performFFT(inputBuffer: samples, bufferSize: Float(self.regularBuffer), bandsPerOctave: self.octaveBands, scale: self.scale)
            }
            
        }
        do {
            
        try self.audioInput.audioSession.setPreferredIOBufferDuration(self.regularBuffer/self.sampleRate)
            
        } catch{
            print("*** audioSession error: \(error)")
        }
        
        audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: 44100, numberOfChannels: 1)
        audioInput.startRecording()
    }
    
    //Countdown selector used to change the timer
    @objc func updateCounter() {
        if(count > 0) {
            count -= 1
            countdownTimer.text = "Recording in... " + String(count)
        }
        else {
            countdownTimer.isHidden = true
            timer.invalidate()
            count = 5
        }
    }
    
    func startTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }

    override func didReceiveMemoryWarning() {
        NSLog("*** Memory!")
        super.didReceiveMemoryWarning()
    }


}
