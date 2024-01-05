//
//  TextureSoketManager.swift
//  DetectBody
//
//  Created by Ishipo on 9/6/23.
//

import Foundation
import Combine

class CameraSocketManager: NSObject, ISocketAction {
    static let shared = CameraSocketManager()
    private var provider: SocketUDPProvider?
    
    var subscriptions = [AnyCancellable]()
    
    
    func changeGateAway(gate: SocketGateAway) {
        provider = SocketUDPProvider(gateAway: gate)
        provider?.connectUDP()
        registerReciveEvent()
    }
    
    func send(data: Data) {
        provider?.sendUDP(data: data)
    }
    
    func registerReciveEvent() {
        provider?.eventPublisher.sink { [weak self] socketEvent in
            if let connectedEvent = socketEvent as? SocketConnectedEvent {
                UserDefault.saveHostUdp(gate: connectedEvent.host)
                UserDefault.saveTexturePort(value: connectedEvent.port)
                print("TextureSoketManager:", "Host: \(connectedEvent.host) , Port: \(connectedEvent.port)")
            }
            
            if let _ = socketEvent as? SocketDidReceiveData {
                print("SocketDidReceiveData")
            }
            if let _ = socketEvent as? SocketDidSendSuccess {
                //print("TextureSocketDidSendSuccess")
            }
        }.store(in: &subscriptions)
    }
}
