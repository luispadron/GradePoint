//
//  UIButtonExtension.swift
//  GradePoint
//
//  Created by Luis Padron on 1/19/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import ObjectiveC
import UIKit

var blockKey = 0
typealias ButtonHandler = () -> Void

// Wrapper for the block object
class BlockWrapper: NSObject {
    
    var block: ButtonHandler
    
    init(block: @escaping ButtonHandler) {
        self.block = block
    }
}


extension UIButton {
    func addHandler(controlEvents events: UIControlEvents,  handler: @escaping ButtonHandler) {
        objc_setAssociatedObject(self, &blockKey, BlockWrapper(block: handler), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        self.addTarget(self, action: #selector(self.handleEvents), for: events)
    }
    
    @objc private func handleEvents() {
        let wrapper = objc_getAssociatedObject(self, &blockKey) as! BlockWrapper
        // Execute the block
        wrapper.block()
    }
}
