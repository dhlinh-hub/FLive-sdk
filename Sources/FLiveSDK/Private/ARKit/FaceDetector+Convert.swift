//
//  FaceDetector+Convert.swift
//  FLiveSDK
//
//  Created by Ishipo on 1/3/24.
//

import Foundation
import Vision

//convert observation to body and hand
extension FaceDetector {
    
    func convertToHand(results: [VNHumanHandPoseObservation]) -> [PossibleHand] {
        var possibleFinger: [PossibleHand] = []
        
        for observation in results {
            // Get points for thumb and index finger.
            guard let thumbPoints = try? observation.recognizedPoints(.thumb) else {
                return []
            }
            guard let indexFingerPoints = try? observation.recognizedPoints(.indexFinger) else {
                return []
            }
            guard  let middleFingerPoints = try? observation.recognizedPoints(.middleFinger) else {
                return []
            }
            guard let ringFingerPoints = try? observation.recognizedPoints(.ringFinger) else {
                return []
            }
            guard let littleFingerPoints = try? observation.recognizedPoints(.littleFinger) else {
                return []
            }
            guard let wristPoints = try? observation.recognizedPoints(.all) else {
                return []
            }
            
            // Look for tip points.
            guard let thumbTipPoint = thumbPoints[.thumbTip],
                  let thumbIpPoint = thumbPoints[.thumbIP],
                  let thumbMpPoint = thumbPoints[.thumbMP],
                  let thumbCMCPoint = thumbPoints[.thumbCMC] else {
                return possibleFinger
            }
            
            guard let indexTipPoint = indexFingerPoints[.indexTip],
                  let indexDipPoint = indexFingerPoints[.indexDIP],
                  let indexPipPoint = indexFingerPoints[.indexPIP],
                  let indexMcpPoint = indexFingerPoints[.indexMCP] else {
                return possibleFinger
            }
            
            guard let middleTipPoint = middleFingerPoints[.middleTip],
                  let middleDipPoint = middleFingerPoints[.middleDIP],
                  let middlePipPoint = middleFingerPoints[.middlePIP],
                  let middleMcpPoint = middleFingerPoints[.middleMCP] else {
                return possibleFinger
            }
            
            guard let ringTipPoint = ringFingerPoints[.ringTip],
                  let ringDipPoint = ringFingerPoints[.ringDIP],
                  let ringPipPoint = ringFingerPoints[.ringPIP],
                  let ringMcpPoint = ringFingerPoints[.ringMCP] else {
                return possibleFinger
            }
            
            guard let littleTipPoint = littleFingerPoints[.littleTip],
                  let littleDipPoint = littleFingerPoints[.littleDIP],
                  let littlePipPoint = littleFingerPoints[.littlePIP],
                  let littleMcpPoint = littleFingerPoints[.littleMCP] else {
                return possibleFinger
            }
            
            guard let wristPoint = wristPoints[.wrist] else {
                return possibleFinger
            }
            
            let minimumConfidence: Float = 0.3
            // Ignore low confidence points.
            guard thumbTipPoint.confidence > minimumConfidence,
                  thumbIpPoint.confidence > minimumConfidence,
                  thumbMpPoint.confidence > minimumConfidence,
                  thumbCMCPoint.confidence > minimumConfidence else {
                return possibleFinger
            }
            
            guard indexTipPoint.confidence > minimumConfidence,
                  indexDipPoint.confidence > minimumConfidence,
                  indexPipPoint.confidence > minimumConfidence,
                  indexMcpPoint.confidence > minimumConfidence else {
                return possibleFinger
            }
            
            guard middleTipPoint.confidence > minimumConfidence,
                  middleDipPoint.confidence > minimumConfidence,
                  middlePipPoint.confidence > minimumConfidence,
                  middleMcpPoint.confidence > minimumConfidence else {
                return possibleFinger
            }
            
            guard ringTipPoint.confidence > minimumConfidence,
                  ringDipPoint.confidence > minimumConfidence,
                  ringPipPoint.confidence > minimumConfidence,
                  ringMcpPoint.confidence > minimumConfidence else {
                return possibleFinger
            }
            
            guard littleTipPoint.confidence > minimumConfidence,
                  littleDipPoint.confidence > minimumConfidence,
                  littlePipPoint.confidence > minimumConfidence,
                  littleMcpPoint.confidence > minimumConfidence else {
                return possibleFinger
            }
            
            guard wristPoint.confidence > minimumConfidence else {
                return possibleFinger
            }
            
            // Convert points from Vision coordinates to AVFoundation coordinates.
            let thumbTip = CGPoint(x: thumbTipPoint.x, y: thumbTipPoint.y)
            let thumbIp = CGPoint(x: thumbIpPoint.x, y: thumbIpPoint.y)
            let thumbMp = CGPoint(x: thumbMpPoint.x, y: thumbMpPoint.y)
            let thumbCmc = CGPoint(x: thumbCMCPoint.x, y: thumbCMCPoint.y)
            
            let indexTip = CGPoint(x: indexTipPoint.x, y: indexTipPoint.y)
            let indexDip = CGPoint(x: indexDipPoint.x, y: indexDipPoint.y)
            let indexPip = CGPoint(x: indexPipPoint.x, y: indexPipPoint.y)
            let indexMcp = CGPoint(x: indexMcpPoint.x, y: indexMcpPoint.y)
            
            let middleTip = CGPoint(x: middleTipPoint.x, y: middleTipPoint.y)
            let middleDip = CGPoint(x: middleDipPoint.x, y: middleDipPoint.y)
            let middlePip = CGPoint(x: middlePipPoint.x, y: middlePipPoint.y)
            let middleMcp = CGPoint(x: middleMcpPoint.x, y: middleMcpPoint.y)
            
            let ringTip = CGPoint(x: ringTipPoint.x, y: ringTipPoint.y)
            let ringDip = CGPoint(x: ringDipPoint.x, y: ringDipPoint.y)
            let ringPip = CGPoint(x: ringPipPoint.x, y: ringPipPoint.y)
            let ringMcp = CGPoint(x: ringMcpPoint.x, y: ringMcpPoint.y)
            
            let littleTip = littleTipPoint.location
            let littleDip = littleDipPoint.location
            let littlePip = littlePipPoint.location
            let littleMcp = littleMcpPoint.location
            
            let wrist = wristPoint.location
            
            possibleFinger.append(PossibleHand(thumb: PossibleThumb(TIP: thumbTip, IP: thumbIp, MP: thumbMp, CMC: thumbCmc),
                                               index: PossibleFinger(TIP: indexTip, DIP: indexDip, PIP: indexPip, MCP: indexMcp),
                                               middle: PossibleFinger(TIP: middleTip, DIP: middleDip, PIP: middlePip, MCP: middleMcp),
                                               ring: PossibleFinger(TIP: ringTip, DIP: ringDip, PIP: ringPip, MCP: ringMcp),
                                               little: PossibleFinger(TIP: littleTip, DIP: littleDip, PIP: littlePip, MCP: littleMcp),
                                               wrist: wrist))
        }
        
        return possibleFinger
    }
    
    func convertToBody(bodyObservation: VNHumanBodyPoseObservation) -> Body {
        var newBody = Body()
        
        if let face = try? bodyObservation.recognizedPoints(.face),
           let nose = face[.nose],
           let leftEye = face[.leftEye],
           let rightEye = face[.rightEye],
           let leftEar = face[.leftEar],
           let rightEar = face[.rightEar] {
            
            if nose.isValidPoint() && leftEar.isValidPoint() && rightEar.isValidPoint() && leftEye.isValidPoint() && rightEye.isValidPoint() {
                newBody.face = Face(nose: nose.location,
                                    leftEye: leftEye.location,
                                    rightEye: rightEye.location,
                                    leftEar: leftEar.location,
                                    rightEar: rightEar.location)
            }
        }
        
        if let torso = try? bodyObservation.recognizedPoints(.torso),
           let neck = torso[.neck] {
            if neck.isValidPoint() {
                newBody.neck = neck.location
            }
        }
        
        if let rightArm = try? bodyObservation.recognizedPoints(.rightArm),
           let rightShoulder = rightArm[.rightShoulder],
           let rightElbow = rightArm[.rightElbow],
           let rightWrist = rightArm[.rightWrist] {
            
            if rightShoulder.isValidPoint() && rightElbow.isValidPoint() && rightWrist.isValidPoint() {
                newBody.rightArm = Arm(shoulder: rightShoulder.location, elbow: rightElbow.location, wrist: rightWrist.location)
            }
        }
        
        if let leftArm = try? bodyObservation.recognizedPoints(.leftArm),
           let leftShoulder = leftArm[.leftShoulder],
           let leftElbow = leftArm[.leftElbow],
           let leftWrist = leftArm[.leftWrist] {
            
            if leftShoulder.isValidPoint() && leftElbow.isValidPoint() && leftWrist.isValidPoint() {
                newBody.leftArm = Arm(shoulder: leftShoulder.location, elbow: leftElbow.location, wrist: leftWrist.location)
            }
        }
        
        if let rightLeg = try? bodyObservation.recognizedPoints(.rightLeg),
           let rightHip = rightLeg[.rightHip],
           let rightKnee = rightLeg[.rightKnee],
           let rightAnkle = rightLeg[.rightAnkle] {
            
            if rightHip.isValidPoint() && rightKnee.isValidPoint() && rightAnkle.isValidPoint() {
                newBody.rightLeg = Leg(hip: rightHip.location, knee: rightKnee.location, ankle: rightAnkle.location)
            }
        }
        
        if let leftLeg = try? bodyObservation.recognizedPoints(.leftLeg),
           let leftHip = leftLeg[.leftHip],
           let leftKnee = leftLeg[.leftKnee],
           let leftAnkle = leftLeg[.leftAnkle] {
            
            if leftHip.isValidPoint() && leftKnee.isValidPoint() && leftAnkle.isValidPoint() {
                newBody.leftLeg = Leg(hip: leftHip.location, knee: leftKnee.location, ankle: leftAnkle.location)
            }
        }
        return newBody
    }
}
