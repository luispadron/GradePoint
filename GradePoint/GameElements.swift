//
//  GameElements.swift
//  GradePoint
//
//  Created by Luis Padron on 1/30/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import SpriteKit

struct CollisionBitMask {
    static let birdCategory:UInt32 = 0x1 << 0
    static let pillarCategory:UInt32 = 0x1 << 1
    static let flowerCategory:UInt32 = 0x1 << 2
    static let groundCategory:UInt32 = 0x1 << 3
}
