//
//  CGPoint+Extension.swift
//  DetectBody
//
//  Created by HungND on 11/08/2023.
//

import Foundation
import Vision
import UIKit

extension CGPoint {
    func convertVisionPointToCGPoint() -> CGPoint {
        let transformedPoint = CGPoint(x: self.x, y: 1 - self.y) // Lật ngược trục y
        return VNImagePointForNormalizedPoint(transformedPoint, Int(UIScreen.main.bounds.width), Int(UIScreen.main.bounds.height))
    }
}
