//
//  UIImage+Extension.swift
//  DetectBody
//
//  Created by HungND on 19/08/2023.
//

import Foundation
import CoreGraphics


extension CGImage {

    func convertCGImageToRawData() -> Data? {
        let width = self.width
        let height = self.height
        let bytesPerPixel = 4 // assuming 32-bit RGBA image
        let bytesPerRow = width * bytesPerPixel
        
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else {
            return nil
        }
        
        let rawData = CFDataCreate(kCFAllocatorDefault, data, bytesPerRow * height)
        return rawData as Data?
    }
}
