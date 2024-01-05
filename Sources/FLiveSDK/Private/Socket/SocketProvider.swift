//
//  SocketProvider.swift
//  DetectBody
//
//  Created by Ishipo on 9/6/23.
//

import Foundation
import CocoaAsyncSocket
import Combine

protocol ISocketAction: AnyObject {
    func send(data: Data)
}
extension ISocketAction {
    func send(data: Data) {}
}

protocol ISocketEvent {}

struct SocketConnectedEvent: ISocketEvent {
    var host: String
    var port: String
}

struct SocketDidReceiveData: ISocketEvent {
    var data: Data
}

struct SocketDidSendSuccess: ISocketEvent {
}

class SocketProvider: NSObject, GCDAsyncSocketDelegate {
    private var socket: GCDAsyncSocket?
    private var gateAway: SocketGateAway
    private var address: Data = Data()
    let eventPublisher = PassthroughSubject<ISocketEvent, Never>()
    
    init(gateAway: SocketGateAway) {
        self.gateAway = gateAway
    }
    
    func connect(){
        socket = GCDAsyncSocket(delegate: self, delegateQueue:DispatchQueue.main)
        let (host, port) = gateAway.components
        do {
            try socket?.connect(toHost: host, onPort: UInt16(port) ?? 0)
        }
        catch { print("joinMulticastGroup not proceed")}
    }
    
    func send(data: Data){
        socket?.write(data, withTimeout: 2, tag: 0)
    }
    
    func send(with splitData: [Data]) {
        for (_, item) in splitData.enumerated() {
            socket?.write(item, withTimeout: 2, tag: 0)
        }
    }
    
    //MARK:- GCDAsyncUdpSocketDelegate
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        eventPublisher.send(SocketConnectedEvent(host: host, port: port.description))
        sock.readData(withTimeout: -1, tag:0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        print("didReceive")
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        //print("didRead")
        eventPublisher.send(SocketDidReceiveData(data: data))
        sock.readData(withTimeout: -1, tag:0)
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        eventPublisher.send(SocketDidSendSuccess())
    }
    
    func socketDidCloseReadStream(_ sock: GCDAsyncSocket){
        print("socketDidCloseReadStream")
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("socketDidDisconnect with err: ", err?.localizedDescription as Any)
    }
}


class SocketUDPProvider: NSObject, GCDAsyncUdpSocketDelegate {
    private var socketUDP: GCDAsyncUdpSocket?
    private var gateAway: SocketGateAway
    private var address: Data = Data()
    let eventPublisher = PassthroughSubject<ISocketEvent, Never>()
    
    init(gateAway: SocketGateAway) {
        self.gateAway = gateAway
    }
    
    func connectUDP(){
        socketUDP = GCDAsyncUdpSocket(delegate: self, delegateQueue:DispatchQueue.main)
        let (host, port) = gateAway.components
        do { try socketUDP?.bind(toPort: UInt16(port) ?? 0)} catch { print("")}
        do { try socketUDP?.connect(toHost: host, onPort: UInt16(port) ?? 0)} catch { print("joinMulticastGroup not proceed")}
        do { try socketUDP?.beginReceiving()} catch { print("beginReceiving not proceed")}
    }
    
    func sendUDP(data: Data){
        socketUDP?.send(data, toAddress: address, withTimeout: 2, tag: 0)
    }
    
    func sendUDP(with splitData: [Data]) {
        for (_, item) in splitData.enumerated() {
            socketUDP?.send(item, toAddress: address, withTimeout: 2, tag: 0)
        }
    }
    
    //MARK:- GCDAsyncUdpSocketDelegate
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        self.address = address
        eventPublisher.send(SocketConnectedEvent(host: gateAway.components.host, port: gateAway.components.port))
        
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        if let _error = error {
            print("didNotConnect \(_error )")
        }
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        eventPublisher.send(SocketDidReceiveData(data: data))
        print("didReceive")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        print("didSendDataWith tag: \(tag) and err: \(error?.localizedDescription as Any)")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        eventPublisher.send(SocketDidSendSuccess())
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        print("udpSocketDidClose with err: ", error?.localizedDescription as Any)
    }
}
