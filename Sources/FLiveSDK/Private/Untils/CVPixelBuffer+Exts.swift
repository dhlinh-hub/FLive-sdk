//
//  CVPixelBuffer.swift
//  DetectBody
//
//  Created by Dang Hung on 17/08/2023.
//

import CoreVideo
import CoreImage
import VideoToolbox
import UIKit

extension CVPixelBuffer {
    
    func toImage() -> UIImage? {
        // Create a CIImage from the pixel buffer
        let ciImage = CIImage(cvPixelBuffer: self)
        
        // Create a UIImage from the CGImage
        let uiImage = UIImage(ciImage: ciImage)
        
        return uiImage
    }
    
    func toCgImage() -> CGImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(self, options: nil, imageOut: &cgImage)
        return cgImage
    }
    
    func getFloat32(x: Float, y: Float) -> Float{
        if(x < 0 || x >= 1 || y < 0 || y >= 1){
            return -1
        }
        else{
            let width = CVPixelBufferGetWidth(self)
            let height = CVPixelBufferGetHeight(self)
            CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
            let depthBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<Float32>.self)
            
            var xP = Int((Float(width) * x).rounded())
            var yP = Int((Float(height) * y).rounded())
            if(xP >= width){xP = width - 1}
            if(yP >= height){yP = height - 1}
            return depthBuffer[width * yP + xP]
        }
    }
    
    func getFloats(points: [Float]) -> [Float]{
        let len = points.count / 2
        var result = [Float](repeating: 0, count: len)
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        let depthBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(self), to: UnsafeMutablePointer<Float32>.self)
        
        var log = ""
        var numNaN = 0;
        
        for vp in 0...(width * height - 1){
            if(depthBuffer[vp].isNaN)
                {numNaN = numNaN + 1}
        }
        
        for i in 0...len-1 {
            let p = i * 2
            let x = points[p], y = points[p + 1]
            
            if(x < 0 || x >= 1 || y < 0 || y >= 1){
                result[i] = -1
            }
            else{
                var xP = Int((Float(width) * x).rounded())
                var yP = Int((Float(height) * y).rounded())
                if(xP >= width){xP = width - 1}
                if(yP >= height){yP = height - 1}
                
                let pos = width * yP + xP;
                var value = depthBuffer[pos];
                
                if(value.isNaN){
                    var iN = 1;
                    while(value.isNaN){
                        if(xP - iN >= 0){
                            value = depthBuffer[pos - iN]
                            if(value.isNaN && xP + iN < width){
                                value = depthBuffer[pos + iN]
                                
                                if(value.isNaN && yP - iN >= 0){
                                    value = depthBuffer[width * (yP - iN) + xP]
                                    
                                    if(value.isNaN && yP + iN < height){
                                        value = depthBuffer[width * (yP + iN) + xP]
                                    }
                                }
                            }
                        }
                        iN = iN + 1
                        if(iN > 10){break}
                    }
                    
                    log += iN.description + "# "
                }
                
                result[i] = value;
                log += result[i].description + ", "
            }
        }
        print("log value: " + numNaN.description + "-" + width.description + "-" + height.description + " :::: " + log)
        return result
    }
    
}
