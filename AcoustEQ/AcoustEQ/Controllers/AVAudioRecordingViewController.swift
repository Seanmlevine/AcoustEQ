//
//  AVAudioRecordingViewController.swift
//  AcoustEQ
//
//  Created by Sean Levine on 3/30/22.
//

import UIKit
import MediaPlayer
import AVKit
import AVFoundation

class AVAudioRecordingViewController: UIViewController, AVAudioRecorderDelegate {
    
    var stackView: UIStackView!
    
    var recordButton: UIButton!
    var playButton: UIButton!

    var recordingSession: AVAudioSession!
    // TODO: - change names to fit my Use Case
    var whistleRecorder: AVAudioRecorder!
    var whistlePlayer: AVAudioPlayer!

    var userFrameSize = UserDefaults.standard.double(forKey: "frameSizeVal")
    var userBandsPerOctave = UserDefaults.standard.integer(forKey: "octaveBandsVal")

    override func loadView() {
        view = UIView()

        view.backgroundColor = UIColor.gray

        stackView = UIStackView()
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        view.addSubview(stackView)

        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Record"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Record", style: .plain, target: nil, action: nil)

        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .defaultToSpeaker])
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        self.loadFailUI()
                    }
                }
            }
        } catch {
            self.loadFailUI()
        }
        
        setAirplayButton()
    }
    
    // MARK: - Loading Options if Permission fails

    func loadRecordingUI() {
        recordButton = UIButton()
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.setTitle("Tap to Record", for: .normal)
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        
        playButton = UIButton()
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setTitle("Tap to Play", for: .normal)
        playButton.isHidden = true
        playButton.alpha = 0
        playButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        
        stackView.addArrangedSubview(playButton)
        stackView.addArrangedSubview(recordButton)
        
    }

    func loadFailUI() {
        let failLabel = UILabel()
        failLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        failLabel.text = "Recording failed: please ensure the app has access to your microphone."
        failLabel.numberOfLines = 0

        stackView.addArrangedSubview(failLabel)
    }
    
    // MARK: - Saving to URL
    
    class func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    class func getWhistleURL() -> URL {
        // TODO: - Change File Name
        return getDocumentsDirectory().appendingPathComponent("whistle.wav")
    }

    func startRecording() {
        // 1
        view.backgroundColor = UIColor(red: 0.6, green: 0, blue: 0, alpha: 1)

        // 2
        recordButton.setTitle("Tap to Stop", for: .normal)

        // 3
        let audioURL = AVAudioRecordingViewController.getWhistleURL()
        print(audioURL.absoluteString)

        // 4
        // TODO: - Change Settings if Necessary
        // https://blog.devgenius.io/ios-avfoundation-series-part-1-4eebaa837d9c
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            // 5
            try recordingSession.setCategory(.playAndRecord, mode: .measurement, options: [.allowBluetooth, .defaultToSpeaker])
            whistleRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            whistleRecorder.delegate = self
            whistleRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)

        whistleRecorder.stop()
        whistleRecorder = nil
        stopSound()

        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
            
            
            // navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)

            let ac = UIAlertController(title: "Record failed", message: "There was a problem recording; please try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
        if playButton.isHidden {
            UIView.animate(withDuration: 0.35) { [unowned self] in
                self.playButton.isHidden = false
                self.playButton.alpha = 1
            }
        }
    }
    
//    @objc func nextTapped() {
//
//    }
    
    @objc func recordTapped() {
        if whistleRecorder == nil {
            startRecording()
//            playSound(file: "sineSweep")
            if !playButton.isHidden {
                UIView.animate(withDuration: 0.35) { [unowned self] in
                    self.playButton.isHidden = true
                    self.playButton.alpha = 0
                }
            }
            
        } else {
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    @objc func playTapped() {
        let audioURL = AVAudioRecordingViewController.getWhistleURL()

        do {
            whistlePlayer = try AVAudioPlayer(contentsOf: audioURL)
            whistlePlayer.play()
        } catch {
            let ac = UIAlertController(title: "Playback failed", message: "There was a problem playing your recording; please try re-recording.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
        do {
            try recordingSession.setCategory(.playback, mode: .default)

        } catch {
            let ac = UIAlertController(title: "Audio Routing Failed", message: "There was a problem routing to playback", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
        let recordingFloat = readURLIntoFloats(audioURL: audioURL)
        let fft = TempiFFT(withSize: Int(userFrameSize), sampleRate: 44100)
        
        fft.fftForward(recordingFloat.signal)
        fft.calculateLogarithmicBands(minFrequency: 20, maxFrequency: 200000, bandsPerOctave: userBandsPerOctave)
        
        //TODO: Find out problem with Logarithmic bands copying value?
        
        let path = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)[0].appendingPathComponent("myFile")

        print(fft.bandMagnitudes!, fft.bandFrequencies!)
        
        let magstringArray = fft.bandMagnitudes.map { String($0) }
        let magstring = magstringArray.joined(separator: ", ")
        
        let freqstringArray = fft.bandMagnitudes.map { String($0) }
        let freqstring = freqstringArray.joined(separator: ", ")
        
        do {
            try freqstring.write(to: path, atomically: true, encoding: .utf8)
            //TODO: separate file path
            try magstring.write(to: path, atomically: true, encoding: .utf8)
            
            
        } catch let error {
            // handle error
            print("Error on writing strings to file: \(error)")
        }
        

    }
    
    func readURLIntoFloats(audioURL: URL) -> (signal: [Float], rate: Double, frameCount: Int) {

        let audioURL = AVAudioRecordingViewController.getWhistleURL()
        print(audioURL)
        let file = try! AVAudioFile(forReading: audioURL)
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: 1, interleaved: false) ?? AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: false)

        let buf = AVAudioPCMBuffer(pcmFormat: format!, frameCapacity: AVAudioFrameCount(file.length))!
        try! file.read(into: buf)

        // this makes a copy, you might not want that
        let floatArray = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
//        print(floatArray)
        
        return (signal: floatArray, rate: file.fileFormat.sampleRate, frameCount: Int(file.length))
        

    }
    
    func setAirplayButton(){
        let buttonView  = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        let routerPickerView =  AVRoutePickerView(frame: buttonView.bounds)
         routerPickerView.tintColor = UIColor.green
         routerPickerView.activeTintColor = .white
         buttonView.addSubview(routerPickerView)
        self.stackView.addSubview(buttonView)
      }
    

}
