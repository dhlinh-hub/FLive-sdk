//
//  FLiveManager.swift
//  FLiveSDK
//
//  Created by Ishipo on 1/4/24.
//

import Foundation

public class FLiveManager : NSObject {
    private static let shared: FLiveManager = FLiveManager()

    public static func instance() -> FLiveManager {
        return shared
    }
    
    public func connectSocket(hort: String, port: String) {
        ControllerSocketManger.shared.connect(gate: .custom(hort, port))
    }
    
}
