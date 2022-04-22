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
    
    public var recFFT = TempiFFT(withSize: 2048, sampleRate: 44100)

    override func loadView() {
        view = UIView()

        view.backgroundColor = .systemGray2

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
        recFFT.windowType = .hanning
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
//        print(audioURL.absoluteString)

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
        
        //MARK: Play Audio
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
        
        //MARK: Convert to Float
        
        let recordingFloat = readURLIntoFloats(audioURL: audioURL)
        
        //MARK: Find next pow of 2 for analyzing recording size
    
        var analysisBufSize = 2048
        var limitReached = false
        
        while !limitReached
        {
                
                if analysisBufSize > recordingFloat.signal.count {
                    analysisBufSize = analysisBufSize / 2
                    limitReached = true
                    break
                } else {
                    analysisBufSize = analysisBufSize * 2
                }
        }
                    
        //MARK: FFT of Audio File
        recFFT = TempiFFT(withSize: analysisBufSize, sampleRate: 44100) // withSize is pow of 2 just less than size of final recording
        
        
        recFFT.fftForward(recordingFloat.signal)
        recFFT.calculateLogarithmicBands(minFrequency: 20, maxFrequency: 200000, bandsPerOctave: userBandsPerOctave)
        
        let minDB: Float = -50.0
        let count = recFFT.numberOfBands
        var totalMagDB: [Float] = []
        var logFreq: [Float] = []
        
        for i in 0..<count {
            let magnitude = recFFT.magnitudeAtBand(i)

            // Incoming magnitudes are linear, making it impossible to see very low or very high values. Decibels to the rescue!
            var magnitudeDB = TempiFFT.toDB(magnitude)

            // Normalize the incoming magnitude so that -Inf = 0
            magnitudeDB = max(0, magnitudeDB + abs(minDB))
            
            totalMagDB.append(magnitudeDB)
            
            
            let frequency = recFFT.frequencyAtBand(i)
            
            let frequencyLog = log(frequency)
            logFreq.append(frequencyLog)
            
        }
        
        

        //MARK: Send band information to graph
        UserDefaults.standard.set(totalMagDB, forKey: "bandMagnitudesDB")
        UserDefaults.standard.set(recFFT.bandMagnitudes!, forKey: "bandMagnitudes")
        UserDefaults.standard.set(logFreq, forKey: "bandFrequenciesLog")
        UserDefaults.standard.set(recFFT.bandFrequencies!, forKey: "bandFrequencies")
        UserDefaults.standard.set(recFFT.numberOfBands, forKey: "bandsCount")
        
        
        // Save magnitude and frequency values to a String file
        let path = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)[0].appendingPathComponent("myFile")
        let path2 = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)[0].appendingPathComponent("myFile2")
        
        let magstringArray = recFFT.bandMagnitudes.map { String($0) }
        let magstring = magstringArray.joined(separator: ", ")
        
        let freqstringArray = recFFT.bandMagnitudes.map { String($0) }
        let freqstring = freqstringArray.joined(separator: ", ")
        
        do {
            try freqstring.write(to: path, atomically: true, encoding: .utf8)
            //TODO: separate file path
            try magstring.write(to: path2, atomically: true, encoding: .utf8)
            
            
        } catch let error {
            // handle error
            print("Error on writing strings to file: \(error)")
        }
        

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
