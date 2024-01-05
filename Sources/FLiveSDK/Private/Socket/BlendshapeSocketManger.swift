//
//  BlendshapeSocketManger.swift
//  DetectBody
//
//  Created by Ishipo on 9/6/23.
//

import Foundation
import Combine

class BlendshapeSocketManger: NSObject, ISocketAction {
    static let shared = BlendshapeSocketManger()
    
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
        provider?.eventPublisher.sink { socketEvent in
            if let connectedEvent = socketEvent as? SocketConnectedEvent {
                UserDefault.saveBlendshapePort(value: connectedEvent.port)
                print("BlendshapeSocketManger:", "Host: \(connectedEvent.host) , Port: \(connectedEvent.port)")
            }
            
            if let _ = socketEvent as? SocketDidReceiveData {
                print("SocketDidReceiveData")
            }
            
            if let _ = socketEvent as? SocketDidSendSuccess {
                //print("BlendSocketDidSendSuccess")
            }
        }.store(in: &subscriptions)
    }
}

