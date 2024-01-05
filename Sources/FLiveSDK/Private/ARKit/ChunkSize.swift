//
//  ChunkSize.swift
//  FLiveSDK
//
//  Created by Ishipo on 1/4/24.
//

import Foundation

internal enum ChunkSize{
    case `defaut` // 63KB
    case custom(Int)
    
    var value: Int {
        switch self {
            case .defaut:
                return 1024*63
            case .custom(let int):
                return int
        }
    }
}
