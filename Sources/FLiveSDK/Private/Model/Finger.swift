//
//  Finger.swift
//  DetectBody
//
//  Created by Ha Duyen Quang Huy on 09/08/2023.
//

import Foundation

public struct Thumb: Codable {
    let TIP: CGPoint
    let IP: CGPoint
    let MP: CGPoint
    let CMC: CGPoint
}

struct PossibleThumb: Codable {
    let TIP: CGPoint?
    let IP: CGPoint?
    let MP: CGPoint?
    let CMC: CGPoint?
}

public struct Finger: Codable {
    let TIP: CGPoint
    let DIP: CGPoint
    let PIP: CGPoint
    let MCP: CGPoint
}

struct PossibleFinger: Codable {
    let TIP: CGPoint?
    let DIP: CGPoint?
    let PIP: CGPoint?
    let MCP: CGPoint?
}


public struct Hand: Codable {
    
    let thumb: Thumb
    let index: Finger
    let middle: Finger
    let ring: Finger
    let little: Finger
    let wrist: CGPoint
}

public struct PossibleHand : Codable {
    let thumb: PossibleThumb?
    let index: PossibleFinger?
    let middle: PossibleFinger?
    let ring: PossibleFinger?
    let little: PossibleFinger?
    let wrist: CGPoint?
}
