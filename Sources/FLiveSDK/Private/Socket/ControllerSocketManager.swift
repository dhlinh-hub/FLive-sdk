//
//  BlendshapeSocketManger.swift
//  DetectBody
//
//  Created by Ishipo on 9/6/23.
//

import Foundation
import Combine

class ControllerSocketManger: NSObject, ISocketAction {
    static let shared = ControllerSocketManger()
    
    private var provider: SocketProvider?
    var subscriptions = [AnyCancellable]()
    public var faceDetector: FaceDetector?
    
    func connect(gate: SocketGateAway) {
        provider = SocketProvider(gateAway: gate)
        provider?.connect()
        registerReciveEvent()
        
    }
    
    func send(data: Data) {
        provider?.send(data: data)
    }
    
    func registerReciveEvent() {
        provider?.eventPublisher.sink { [weak self] socketEvent in
            if let connectedEvent = socketEvent as? SocketConnectedEvent {
                UserDefault.saveControllerPort(value: connectedEvent.port)
                print("ControllerSocketManger:", "Host: \(connectedEvent.host) , Port: \(connectedEvent.port)")
            }
            
            if let receiveEvent = socketEvent as? SocketDidReceiveData {
                //print("SocketDidReceiveData")
                self?.receiveData(data: receiveEvent.data)
            }
            
            if let _ = socketEvent as? SocketDidSendSuccess {
                //print("BlendSocketDidSendSuccess")
            }
        }.store(in: &subscriptions)
    }
    
    func receiveData(data: Data){
        if(data.count < 4) {return}
        
        let streamData = MemoryStream(data: data)
        let code = Int(streamData.read(Int32.self))
        if(code == AppContants.REQUEST_DEPTH_CODE){
            let timestamp = streamData.read(Int.self)
            
            let len = Int(streamData.read(Int32.self))
            var points = [Float](repeating:0, count: len * 2)
            for i in 0...len-1 {
                let p = i * 2
                points[p] = streamData.read(Float32.self)
                points[p + 1] = streamData.read(Float32.self)
            }
            faceDetector?.responseDepthData(timestamp: timestamp, points: points)
        }
    }
    
    func sendResponseDepth(timestamp: Int, points: [Float], depthPoints: [Float]){
        var data = Data()
        let len = depthPoints.count
        withUnsafeBytes(of: AppContants.RESULT_DEPTH_CODE) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: timestamp) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: len) { data.append(contentsOf: $0)}
        
        for i in 0...len-1 {
            withUnsafeBytes(of: points[i*2]) { data.append(contentsOf: $0)}
            withUnsafeBytes(of: points[i*2 + 1]) { data.append(contentsOf: $0)}
            withUnsafeBytes(of: depthPoints[i]) { data.append(contentsOf: $0)}
        }
        
        provider?.send(data: data)
    }
}
