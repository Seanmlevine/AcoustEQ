//
//  Extensions.swift
//  AcoustEQ
//
//  Created by Sean Levine on 11/30/21.
//

import UIKit
import AVFoundation

extension UIColor {
    convenience init(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hexString).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}


extension Array {
    var bytes: [UInt8] { withUnsafeBytes { .init($0) } }
    var data: Data { withUnsafeBytes { .init($0) } }
}
extension ContiguousBytes {
    func object<T>() -> T { withUnsafeBytes { $0.load(as: T.self) } }
    func objects<T>() -> [T] { withUnsafeBytes { .init($0.bindMemory(to: T.self)) } }
}
//https://stackoverflow.com/questions/64234225/how-to-save-a-float-array-in-swift-as-txt-file

//let values: [Float] = [-.pi, .zero, .pi, 1.5, 2.5]
//let bytes = values.bytes  // [218, 15, 73, 192, 0, 0, 0, 0, 218, 15, 73, 64, 0, 0, 192, 63, 0, 0, 32, 64]
//let data = values.data    // 20 bytes
//let minusPI: Float = data.subdata(in: 0..<4).object() // -3.141593
//let loaded1: [Float] = bytes.objects()  // [-3.141593, 0, 3.141593, 1.5, 2.5]
//let loaded2: [Float] = data.objects()   // [-3.141593, 0, 3.141593, 1.5, 2.5]
