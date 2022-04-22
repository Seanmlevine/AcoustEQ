//
//  ChartsDemo.swift
//  AcoustEQ
//
//  Created by Sean Levine on 4/20/22.
//

import Foundation
import UIKit
import Charts
import TinyConstraints

class ChartController: UIViewController, ChartViewDelegate {
    
    var recordingAudio: AVAudioRecordingViewController!
    let markerView = MarkerView()
   
    
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()

        chartView.backgroundColor = .systemGray2
        
        
        chartView.rightAxis.enabled = false
        let yAxis = chartView.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .white
        yAxis.axisLineColor = .white
        yAxis.labelPosition = .outsideChart
        
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        chartView.xAxis.setLabelCount(6, force: false)
        chartView.xAxis.labelTextColor = .white
        chartView.xAxis.axisLineColor = .white

        
        let xArr = UserDefaults.standard.array(forKey: "bandFrequencies") as! [Float]
        var stringArray = xArr.map { String(Int($0)) }
        print(xArr)
        
//        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: stringArray)
        chartView.xAxis.granularity = 1
        
        chartView.animate(yAxisDuration: 2.5) // logarithmic axes
        chartView.chartDescription?.text = "X: Frequency (Hz), Y: Magnitude(dBC)"
        
        return chartView
            
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        view.addSubview(lineChartView)
        view.backgroundColor = .systemGray2
        lineChartView.centerInSuperview()
        lineChartView.width(to: view)
        lineChartView.heightToWidth(of: view)
        
        
//        setData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setData()
    }
    
    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    
    func setData() {
        fftData()
        let set1 = LineChartDataSet(entries: dataEntries, label: "Frequency Response")
        
        set1.mode = .cubicBezier
        set1.drawCirclesEnabled = false
        set1.lineWidth = 3
        set1.setColor(.white)
        set1.highlightColor = .systemRed

        
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(true)
        lineChartView.data = data
    }
    
    var dataEntries: [ChartDataEntry] = []
    
    func fftData() {
        let defaults = UserDefaults.standard
        let count = defaults.integer(forKey: "bandsCount")
//        let xArr = defaults.array(forKey: "bandFrequencies") as! [String] // was linear
        let xArrLog = defaults.array(forKey: "bandFrequenciesLog") as! [Float]
//        let yArr = defaults.array(forKey: "bandMagnitudes") as! [Float] // was linear
        let yArr = defaults.array(forKey: "bandMagnitudesDB") as! [Float]
        print(xArrLog)
        
        
        
        
        for i in 0..<count {
            
            let dataEntry = ChartDataEntry(x: Double(xArrLog[i]), y: Double(yArr[i]))

            dataEntries.append(dataEntry)
        }
//        print(dataEntries)
        
    }
    
    // For EQ Initialization
    // split total frequency range into 8
    // average across each range
    
}
