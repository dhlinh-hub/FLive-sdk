//
//  BlendshapeMap.swift
//  DetectBody
//
//  Created by Admin on 09/10/2023.
//

import Foundation
import ARKit
typealias BlendshapeKey = ARFaceAnchor.BlendShapeLocation

extension ARFaceAnchor{
    public func convertData() -> Data{
        let blendshapes = self.blendShapes
        var data = Data(capacity: 52 * 4)
        withUnsafeBytes(of: blendshapes[BlendshapeKey.browDownLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.browDownRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.browInnerUp]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.browOuterUpLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.browOuterUpRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.cheekPuff]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.cheekSquintLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.cheekSquintRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.eyeBlinkLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.eyeBlinkRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.eyeLookDownLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.eyeLookDownRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.eyeLookInLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.eyeLookInRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.eyeLookOutLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.eyeLookOutRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.eyeLookUpLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.eyeLookUpRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.eyeSquintLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.eyeSquintRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.eyeWideLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.eyeWideRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.jawForward]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.jawLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.jawOpen]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.jawRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthClose]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthDimpleLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthDimpleRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthFrownLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthFrownRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthFunnel]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthLowerDownLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthLowerDownRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthPressLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthPressRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthPucker]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthRollLower]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthRollUpper]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthShrugLower]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthShrugUpper]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthSmileLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthSmileRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthStretchLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthStretchRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthUpperUpLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.mouthUpperUpRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.noseSneerLeft]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.noseSneerRight]!.floatValue) { data.append(contentsOf: $0)}
        withUnsafeBytes(of: blendshapes[BlendshapeKey.tongueOut]!.floatValue) { data.append(contentsOf: $0)}
        return data
    }
}
