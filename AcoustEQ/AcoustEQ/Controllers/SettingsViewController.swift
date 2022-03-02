//
//  SettingsViewController.swift
//  AcoustEQ
//
//  Created by Sean Levine on 12/7/21.
//

import UIKit

//TODO: FIX LANDSCAPE SCROLL VIEW

// create protocol delegate to allow changing of parameters
protocol setFreqResponseDelegate {
    func setFreqResponse(frameSize: Int, octaveBand: Int, scale: String)
}

class SettingsViewController: UIViewController {
    var settingFrameSize = 2048
    var settingOctaveBand = 8
    var settingScale = "Logarithm"
    let freqController = FreqRespViewController()
//    var settingWindow = TempiFFTWindowType.hanning
    
    public var delegate: setFreqResponseDelegate?
    
    
    @IBOutlet weak var frameSizeControl: UISegmentedControl!
    @IBOutlet weak var octaveBandControl: UISegmentedControl!
    @IBOutlet weak var scaleControl: UISegmentedControl!
//    @IBOutlet weak var windowControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //TODO: FIX CORRECT PARAMS ON LOAD (USER DEFAULT)
    override func viewWillAppear(_ animated: Bool) {
        let fr_index = UserDefaults.standard.integer(forKey: "frameSize")
        frameSizeControl.selectedSegmentIndex = fr_index
        settingFrameSize = UserDefaults.standard.integer(forKey: "frameSizeVal")
        
        let oc_index = UserDefaults.standard.integer(forKey: "octaveBands")
        octaveBandControl.selectedSegmentIndex = oc_index
        settingOctaveBand = UserDefaults.standard.integer(forKey: "octaveBandsVal")

        
        let sc_index = UserDefaults.standard.integer(forKey: "scale")
        scaleControl.selectedSegmentIndex = sc_index
        settingScale = UserDefaults.standard.string(forKey: "scaleVal") ?? "Logarithm"

        
//        let wi_index = UserDefaults.standard.integer(forKey: "window")
//        windowControl.selectedSegmentIndex = wi_index

    }
    @IBAction func frameSizeChanged(_ sender: UISegmentedControl) {
        let fs_values = [512, 1024, 2048, 4096]
        settingFrameSize = fs_values[sender.selectedSegmentIndex]
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "frameSize")
        UserDefaults.standard.set(settingFrameSize, forKey: "frameSizeVal")
        
    }
    
    @IBAction func octaveBandChanged(_ sender: UISegmentedControl) {
        let oc_values = [1, 3, 6, 8]
        settingOctaveBand = oc_values[sender.selectedSegmentIndex]
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "octaveBands")
        UserDefaults.standard.set(settingOctaveBand, forKey: "octaveBandsVal")
    }
    @IBAction func scaleChanged(_ sender: UISegmentedControl) {
        let sc_values = ["Logarithm", "Linear"]
        settingScale = sc_values[sender.selectedSegmentIndex]
        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "scale")
        UserDefaults.standard.set(settingScale, forKey: "scaleVal")
    }
//    @IBAction func windowChanged(_ sender: UISegmentedControl) {
//        if sender.selectedSegmentIndex == 0 {
//            fft.windowType = .hanning
//        }
//        else if sender.selectedSegmentIndex == 1 {
//            fft.windowType = .hamming
//        }
//        windowControl.selectedSegmentIndex = sender.selectedSegmentIndex
//        UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "window")
//    }
    
    // when view disappears, use delegate to change the variables in the other views
    override func viewDidDisappear(_ animated: Bool) {
        delegate?.setFreqResponse(frameSize: settingFrameSize, octaveBand: settingOctaveBand, scale: settingScale)
    }
    
    

}
