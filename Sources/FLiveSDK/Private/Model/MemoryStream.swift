//
//  MemoryStream.swift
//  DetectBody
//
//  Created by Admin on 13/10/2023.
//

import Foundation

class MemoryStream{
    private let data: [UInt8]
    private var pos = 0
    
    public init(data: Data){
        self.data = data.toByte()
        pos = 0
    }
    
    public func canRead() -> Bool{
        return pos >= data.count
    }
    
    public func read<T>(_: T.Type) -> T{
        let size = MemoryLayout<T>.size
        var value = data[pos ..< (pos + size)]
        pos += size
        return value.withUnsafeMutableBytes{
            $0.baseAddress!.load(as: T.self)
        }
    }
}
