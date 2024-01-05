//
//  DataProcessor.swift
//  DetectBody
//
//  Created by Ishipo on 9/6/23.
//

import UIKit
import ARKit

class DataTrackingProcessor: Operation {
    
    private let frame: ARFrame
    private(set) var data: Data = Data()
    let id: Int
    
    public init(frame: ARFrame, id: Int) {
        self.frame = frame
        self.id = id
    }
    
    public override func main() {
        
        guard let texture = frame.capturedImage.toImage() else { return }
        guard let textureData = texture.jpegData(compressionQuality: 0.1)?.toByte() else { return }
        
        let imgWidth = Int(texture.size.width)
        let imgHeight = Int(texture.size.height)
        let time = Double(frame.timestamp)
        
        withUnsafeBytes(of: AppContants.TEXTURE_CODE.bigEndian) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: time){data.append(contentsOf: $0)}
        withUnsafeBytes(of: imgWidth.bigEndian) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: imgHeight.bigEndian) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: textureData.count.bigEndian) { data.append(contentsOf: $0)}
        data.append(contentsOf: textureData)
        
        let hasDepthData = true
        if(hasDepthData){
            if let depthImg = frame.capturedDepthData?.depthDataMap.toImage() {
                let depthCompress = depthImg.jpegData(compressionQuality: 0.1)?.toByte() ?? []
                let depthWidth = Int(depthImg.size.width)
                let depthHeight = Int(depthImg.size.height)
                withUnsafeBytes(of: depthWidth.bigEndian) { data.append(contentsOf: $0)}
                withUnsafeBytes(of: depthHeight.bigEndian) { data.append(contentsOf: $0)}
                withUnsafeBytes(of: depthCompress.count.bigEndian) { data.append(contentsOf: $0)}
                data.append(contentsOf: depthCompress)
                return
            }
        }
        
        withUnsafeBytes(of: 0.bigEndian) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: 0.bigEndian) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: 0.bigEndian) { data.append(contentsOf: $0)}
    }
}

extension OperationQueue {
    public var runningOperations: [Operation] {
        return operations.filter {$0.isExecuting && !$0.isFinished && !$0.isCancelled}
    }
}
