//
//  EqualizerView.swift
//  AcoustEQ
//
//  Created by Sean Levine on 11/30/21.
//

import UIKit
//import PureLayout

protocol EqualizerViewDelegate: AnyObject {
    func trimmed(to freqRange: ClosedRange<Float>)
}

class EqualizerView: UIView {

    
    var time: TimeInterval = 0 {
        didSet {
            spectrumView.time = time
        }
    }

    weak var delegate: EqualizerViewDelegate?

    private var spectrumView: SpectrumView!

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear

        spectrumView = SpectrumView()
        addSubview(spectrumView)
        spectrumView.autoPinEdgesToSuperviewEdges()

    }
}


