//
//  SocketGateAway.swift
//  DetectBody
//
//  Created by Ishipo on 9/6/23.
//

import Foundation

public enum SocketGateAway {
    case texture
    case blendShape
    case custom(String, String)
    
    public var components: (host: String, port: String) {
        switch self {
            case .texture:
                return ("10.211.55.3", "1121")
            case .blendShape:
                return ("10.211.55.3", "1120")
            case.custom(let domain, let path):
                return (domain, path)
        }
    }
}
