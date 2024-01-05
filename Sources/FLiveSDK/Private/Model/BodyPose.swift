//
//  BodyPose.swift
//  HandPose
//
//  Created by HungND on 09/08/2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

public struct Arm: Codable {
   public let shoulder: CGPoint
   public let elbow: CGPoint
   public let wrist: CGPoint
}

public struct Leg: Codable {
   public let hip: CGPoint
   public let knee: CGPoint
   public let ankle: CGPoint
}

public struct Face: Codable {
   public var nose: CGPoint
   public var leftEye: CGPoint
   public var rightEye: CGPoint
   public var leftEar: CGPoint
   public var rightEar: CGPoint
}

public struct Body: Codable {
   public var neck: CGPoint?
   public var face: Face?
   public var leftArm: Arm?
   public var rightArm: Arm?
   public var leftLeg: Leg?
   public var rightLeg: Leg?
}

public struct BodyWithHandPose: Codable {
   public var hands: [Hand]?
   public var body: Body?
}
