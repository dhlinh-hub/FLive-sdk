//
//  VNRecognizedPoint+.swift
//  DetectBody
//
//  Created by Ha Duyen Quang Huy on 10/08/2023.
//

import Vision

extension VNRecognizedPoint {
    func isValidPoint() -> Bool {
        return self.confidence > AppContants.MINIMUM_CONFIDENCE
    }
}
