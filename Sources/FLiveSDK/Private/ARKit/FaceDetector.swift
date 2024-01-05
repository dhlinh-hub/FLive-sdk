//
//  FaceDetector.swift
//  DetectBody
//
//  Created by Ishipo on 9/13/23.
//

import Foundation
import UIKit
import ARKit
import Vision

protocol FaceDetectorDelegate: AnyObject {
    func detector(sceneView detector: FaceDetector) -> ARSCNView
    func detector(showFaceMesh detector: FaceDetector) -> Bool
}

class FaceDetector: NSObject {
    
    private lazy var handPoseRequest: VNDetectHumanHandPoseRequest = {
        let request = VNDetectHumanHandPoseRequest()
        request.maximumHandCount = 2
        return request
    }()
    
    private lazy var bodyPoseRequest = VNDetectHumanBodyPoseRequest()
    
    private lazy var dataTrackingProcessorOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "DataProcessorQueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private var packageId = 0
    private var isTrackingPose = false
    
//    weak var model: ARTrackingViewModel?
    weak var delegate: FaceDetectorDelegate?
    
    let textureSendingQueue = DispatchQueue(label: "com.camera.sending", attributes: .concurrent)
    let blendshapeSendingQuee = DispatchQueue(label: "com.blend_shape.sending", attributes: .concurrent)
    
    var depthDataMap = [Int: CVPixelBuffer]()
    
    internal func detectorDidActive() {
        dataTrackingProcessorOperationQueue.isSuspended = false
    }
    
    internal func detectorDidRelease() {
        dataTrackingProcessorOperationQueue.cancelAllOperations()
        dataTrackingProcessorOperationQueue.isSuspended = true
    }
}

//MARK: ARKit
extension FaceDetector : ARSCNViewDelegate, ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            //self.captureOutput(didOutput: frame.capturedImage)
            if(frame.capturedDepthData != nil){
                self.packageId += 1
                self.processingTexture(frame: frame, packageId: self.packageId)
            }
        }
    }
    
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]){
        if(anchors.count > 0){
            let anchor = anchors[0]
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                guard let faceAnchor = anchor as? ARFaceAnchor else {return}
                self.processingBlendshape(faceAnchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let delegate = delegate else { return nil}
        let faceMesh = ARSCNFaceGeometry(device: delegate.detector(sceneView: self).device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        
        return delegate.detector(showFaceMesh: self) ? node : nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
        faceGeometry.update(from: faceAnchor.geometry)
    }
    
    private func processingTexture(frame: ARFrame, packageId: Int) {
        let dataOperation = DataTrackingProcessor(frame: frame, id: packageId)
        
        let splitOperation = BlockOperation {
            self.split(data: dataOperation.data, id: dataOperation.id)
        }
        
        splitOperation.addDependency(dataOperation)
        dataTrackingProcessorOperationQueue.addOperation(splitOperation)
        dataTrackingProcessorOperationQueue.addOperation(dataOperation)
        
        //cache depth data
        if(depthDataMap.count > 10){
            depthDataMap.remove(at: depthDataMap.startIndex)
        }
        
        let timeLong = Int(frame.timestamp * 1000000)
        depthDataMap[timeLong] = frame.capturedDepthData?.depthDataMap
    }
    
    private func split(data: Data, id: Int, chunkSize: ChunkSize = .custom(1024*20)) {
        
        let totalSize = data.count
        var offset = 0
        var indx = 0
        
        while offset < totalSize {
            let remainingSize = totalSize - offset
            let currentChunkSize = min(chunkSize.value, remainingSize)
            let chunkRange = offset..<offset + currentChunkSize
            var chunkData = Data()
            chunkData.append(addHeaderPackage(curr: offset, total: totalSize, id: id))
            chunkData.append(data.subdata(in: chunkRange))
            self.textureSendingQueue.async {
                CameraSocketManager.shared.send(data: chunkData)
            }
            indx += 1
            offset += currentChunkSize
        }
    }
    
    private func addHeaderPackage(curr: Int, total: Int, id: Int) -> Data {
        var headerData = Data()
        withUnsafeBytes(of: id.bigEndian) { headerData.append(contentsOf: $0)}
        withUnsafeBytes(of: curr.bigEndian) { headerData.append(contentsOf: $0)}
        withUnsafeBytes(of: total.bigEndian) { headerData.append(contentsOf: $0)}
        return headerData
    }
    
    private func processingBlendshape(_ faceAnchor: ARFaceAnchor) {
        DispatchQueue.global().async { [weak self] in
            var blenshapeData = Data()
            withUnsafeBytes(of: AppContants.BLENDSHAPE_CODE.bigEndian) { blenshapeData.append(contentsOf: $0)}
            
            let transform = faceAnchor.transform
            for i in 0...3 {
                for j in 0...3 {
                    withUnsafeBytes(of: transform[i][j]) { blenshapeData.append(contentsOf: $0) }
                }
            }
            
            blenshapeData.append(faceAnchor.convertData())
            //            do {
            //                let blendShapes = faceAnchor.blendShapes
            //                let data = try JSONSerialization.data(withJSONObject: blendShapes)
            //                blenshapeData.append(data)
            //            } catch {
            //                print("Error converting blendshapes to data: \(error)")
            //            }
            self?.sendingBlendshape(data: blenshapeData)
        }
    }
    
    private func sendingBlendshape(data: Data) {
        self.blendshapeSendingQuee.async {
            BlendshapeSocketManger.shared.send(data: data)
        }
    }
    
    public func responseDepthData(timestamp: Int, points: [Float]){
        guard let data = depthDataMap[timestamp] else {return}
        let overDepths = depthDataMap.filter({($0.key <= timestamp)})
        for(key, _) in overDepths{
            depthDataMap.removeValue(forKey: key)
        }
        
        let result = data.getFloats(points: points)
        print("responseDepthData: ", CVPixelBufferGetDataSize(data), depthDataMap.capacity, timestamp)
        ControllerSocketManger.shared.sendResponseDepth(timestamp: timestamp, points: points, depthPoints: result)
    }
}

extension FaceDetector {
    func captureOutput(didOutput imageBuffer: CVPixelBuffer) {
        var possibleFinger: [PossibleHand] = []
        var body = Body()
        
        defer {
            self.processPoints(fingers: possibleFinger, body: body)
        }
        
        guard isTrackingPose else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: .up)
        do {
            // Perform VNDetectHumanHandPoseRequest
            try handler.perform([handPoseRequest, bodyPoseRequest])
            
            if let bodyResults = bodyPoseRequest.results?.first {
                DispatchQueue.global().async { [weak self] in
                    body = self?.convertToBody(bodyObservation: bodyResults) ?? Body()
                }
            }
            
            // Continue only when at least a hand was detected in the frame. We're interested in maximum of two hands.
            guard let results = handPoseRequest.results?.prefix(2), !results.isEmpty else {
                possibleFinger = []
                return
            }
            DispatchQueue.global().async { [weak self] in
                possibleFinger = self?.convertToHand(results: Array(results)) ?? []
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
}



extension FaceDetector {
    func processPoints(fingers: [PossibleHand], body: Body) {
        var bodyWithHands = BodyWithHandPose()
        guard isTrackingPose else { return}
        var newBody = Body()
        var hands = [Hand]()
        
        for finger in fingers {
            guard let thumbTip = finger.thumb?.TIP,
                  let thumbIp = finger.thumb?.IP,
                  let thumbMp = finger.thumb?.MP,
                  let thumbCmc = finger.thumb?.CMC,
                  let indexTip = finger.index?.TIP,
                  let indexDip = finger.index?.DIP,
                  let indexPip = finger.index?.PIP,
                  let indexMcp = finger.index?.MCP,
                  let middleTip = finger.middle?.TIP,
                  let middleDip = finger.middle?.DIP,
                  let middlePip = finger.middle?.PIP,
                  let middleMcp = finger.middle?.MCP,
                  let ringTip = finger.ring?.TIP,
                  let ringDip = finger.ring?.DIP,
                  let ringPip = finger.ring?.PIP,
                  let ringMcp = finger.ring?.MCP,
                  let littleTip = finger.little?.TIP,
                  let littleDip = finger.little?.DIP,
                  let littlePip = finger.little?.PIP,
                  let littleMcp = finger.little?.MCP,
                  let wrist = finger.wrist else {
                
                continue
            }
            
            // Convert points from AVFoundation coordinates to UIKit coordinates.
            let thumbTipConverted =  thumbTip.convertVisionPointToCGPoint()
            let thumbIpConverted = thumbIp.convertVisionPointToCGPoint()
            let thumbMpConverted = thumbMp.convertVisionPointToCGPoint()
            let thumbCmcConverted = thumbCmc.convertVisionPointToCGPoint()
            
            let indexTipConverted =  indexTip.convertVisionPointToCGPoint()
            let indexDipConverted = indexDip.convertVisionPointToCGPoint()
            let indexPipConverted =  indexPip.convertVisionPointToCGPoint()
            let indexMcpConverted =   indexMcp.convertVisionPointToCGPoint()
            
            let middleTipConverted =  middleTip.convertVisionPointToCGPoint()
            let middleDipConverted =  middleDip.convertVisionPointToCGPoint()
            let middlePipConverted = middlePip.convertVisionPointToCGPoint()
            let middleMcpConverted = middleMcp.convertVisionPointToCGPoint()
            
            let ringTipConverted = ringTip.convertVisionPointToCGPoint()
            let ringDipConverted = ringDip.convertVisionPointToCGPoint()
            let ringPipConverted = ringPip.convertVisionPointToCGPoint()
            let ringMcpConverted = ringMcp.convertVisionPointToCGPoint()
            
            let littleTipConverted = littleTip.convertVisionPointToCGPoint()
            let littleDipConverted = littleDip.convertVisionPointToCGPoint()
            let littlePipConverted = littlePip.convertVisionPointToCGPoint()
            let littleMcpConverted = littleMcp.convertVisionPointToCGPoint()
            
            let wristConverted = wrist.convertVisionPointToCGPoint()
            
            // Process new points
            let newHand = Hand(thumb: Thumb(TIP: thumbTipConverted, IP: thumbIpConverted, MP: thumbMpConverted, CMC: thumbCmcConverted),
                               index: Finger(TIP: indexTipConverted, DIP: indexDipConverted, PIP: indexPipConverted, MCP: indexMcpConverted),
                               middle: Finger(TIP: middleTipConverted, DIP: middleDipConverted, PIP: middlePipConverted, MCP: middleMcpConverted),
                               ring: Finger(TIP: ringTipConverted, DIP: ringDipConverted, PIP: ringPipConverted, MCP: ringMcpConverted),
                               little: Finger(TIP: littleTipConverted, DIP: littleDipConverted, PIP: littlePipConverted, MCP: littleMcpConverted),
                               wrist: wristConverted)
            
            hands.append(newHand)
        }
        
        bodyWithHands.hands = hands
        
        if let face = body.face {
            let nose = face.nose.convertVisionPointToCGPoint()
            let leftEye = face.leftEye.convertVisionPointToCGPoint()
            let rightEye = face.rightEye.convertVisionPointToCGPoint()
            let leftEar = face.leftEar.convertVisionPointToCGPoint()
            let rightEar =  face.rightEar.convertVisionPointToCGPoint()
            
            newBody.face = Face(nose: nose, leftEye: leftEye, rightEye: rightEye, leftEar: leftEar, rightEar: rightEar)
        }
        
        if let neck = body.neck {
            newBody.neck = neck.convertVisionPointToCGPoint()
        }
        
        if let rightArm = body.rightArm {
            let shoulder =  rightArm.shoulder.convertVisionPointToCGPoint()
            let elbow = rightArm.elbow.convertVisionPointToCGPoint()
            let wrist =  rightArm.wrist.convertVisionPointToCGPoint()
            
            newBody.rightArm = Arm(shoulder: shoulder, elbow: elbow, wrist: wrist)
        }
        
        if let leftArm = body.leftArm {
            let shoulder =  leftArm.shoulder.convertVisionPointToCGPoint()
            let elbow =  leftArm.elbow.convertVisionPointToCGPoint()
            let wrist = leftArm.wrist.convertVisionPointToCGPoint()
            
            newBody.leftArm = Arm(shoulder: shoulder, elbow: elbow, wrist: wrist)
        }
        
        if let rightLeg = body.rightLeg {
            let hip = rightLeg.hip.convertVisionPointToCGPoint()
            let knee = rightLeg.knee.convertVisionPointToCGPoint()
            let ankle = rightLeg.ankle.convertVisionPointToCGPoint()
            
            newBody.rightLeg = Leg(hip: hip, knee: knee, ankle: ankle)
        }
        
        if let leftLeg = body.leftLeg {
            let hip =  leftLeg.hip.convertVisionPointToCGPoint()
            let knee =  leftLeg.knee.convertVisionPointToCGPoint()
            let ankle = leftLeg.ankle.convertVisionPointToCGPoint()
            
            newBody.leftLeg = Leg(hip: hip, knee: knee, ankle: ankle)
        }
        
        bodyWithHands.body = newBody
        
//        model?.perform(action: .bodyObrvseationDetected(bodyWithHands))
    }
}

