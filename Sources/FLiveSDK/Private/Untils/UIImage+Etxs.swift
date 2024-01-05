//
//  UIImage + Etx.swift
//  DetectBody
//
//  Created by Ishipo on 9/5/23.
//

import UIKit

extension UIImage {
    func convertImageToBytes(compressionQuality: CGFloat = 0.1) -> [UInt8]? {
        guard let imageData = self.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }
        
        let byteArray = [UInt8](imageData)
        return byteArray
    
    }
    
    func resize(targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        let resizedImage = renderer.image { context in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        return resizedImage
    }
}
