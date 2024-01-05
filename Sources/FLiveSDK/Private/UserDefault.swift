//
//  UserDefault.swift
//  DetectBody
//
//  Created by Ishipo on 9/14/23.
//

import Foundation

internal class UserDefault {
    private static let kHostUdp = "detect.body.host_udp"
    private static let kTexturePort = "detect.body.texture_port"
    private static let kBlendshapePort = "detect.body.blendshape_port"
    private static let kControllerPort = "detect.body.controller_port"

    
    static func saveHostUdp(gate: String) {
        UserDefaults.standard.set(gate, forKey: kHostUdp)
    }
    
    static func saveTexturePort(value: String) {
        UserDefaults.standard.set(value, forKey: kTexturePort)
    }
    
    static func saveBlendshapePort(value: String) {
        UserDefaults.standard.set(value, forKey: kBlendshapePort)
    }
    
    static func saveControllerPort(value: String) {
        UserDefaults.standard.set(value, forKey: kControllerPort)
    }
    
    static func getHostUdp() -> String? {
        UserDefaults.standard.string(forKey: kHostUdp)
    }
    
    static func getTexturePort() -> String? {
        UserDefaults.standard.string(forKey: kTexturePort)
    }
    
    static func getBlendshapePort() -> String? {
        UserDefaults.standard.string(forKey: kBlendshapePort)
    }
    
    static func getControllerPort() -> String? {
        UserDefaults.standard.string(forKey: kControllerPort)
    }
    
    static func removeAuth() {
        UserDefaults.standard.removeObject(forKey: kHostUdp)
        UserDefaults.standard.removeObject(forKey: kTexturePort)
        UserDefaults.standard.removeObject(forKey: kBlendshapePort)
        UserDefaults.standard.removeObject(forKey: kControllerPort)
        UserDefaults.standard.synchronize()
    }
}
