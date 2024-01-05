//
//  Data + Ext.swift
//  DetectBody
//
//  Created by Ishipo on 8/29/23.
//

import Foundation

extension Data {
    func toByte() -> [UInt8] {
        var byteArray = [UInt8](repeating: 0, count: self.count)
        self.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) in
            guard let rawPtr = pointer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                return
            }
            let buffer = UnsafeBufferPointer(start: rawPtr, count: self.count)
            byteArray = Array(buffer)
        }
        return byteArray
    }
}

extension NSDate{
    func now() ->TimeInterval{
        return NSDate().timeIntervalSince1970 * 1000 * 1000
    }
}
