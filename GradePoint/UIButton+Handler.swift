//
//  UIButton+Handler.swift
//  GradePoint
//
//  Created by Luis Padron on 2/7/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

public typealias ButtonHandler = () -> Void

/// The wrapper for our handler, for some reason Xcode got super confused when I used a type alias...
open class HandlerWrapper: NSObject {
    open var handler: ButtonHandler
    
    public init(handler: @escaping ButtonHandler) {
        self.handler = handler
    }
}

/// Extension on UIButton which adds a handler associated property
extension UIButton {
    /// The key for the saving the value, required by objc
    private struct SaveKey {
        static var key = "com.luispadron.GradePoint.saveKey"
    }

    /// The handler for the button
    public var handler: HandlerWrapper? {
        set { objc_setAssociatedObject(self, &SaveKey.key, newValue, .OBJC_ASSOCIATION_RETAIN) }
        get { return objc_getAssociatedObject(self, &SaveKey.key) as? HandlerWrapper }
    }
    
    
    /// Adds a handler to a button, hanlder must be called with a weak or unowned self as it is escaping
    public func addHandler(forEvents events: UIControl.Event, handler: @escaping ButtonHandler) {
        self.handler = HandlerWrapper(handler: handler)
        self.addTarget(self, action: #selector(self.buttonTapped), for: events)
    }
    
    /// Called when button is tapped, will call the handler that was set in `addHandler(:)`
    @objc private func buttonTapped() {
        
        self.animateWithPulse(withDuration: 0.25) {
            // Call the handler
            self.handler?.handler()
        }
    }
}
