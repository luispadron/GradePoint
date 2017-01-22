//
//  UIHandlerButton.swift
//  GradePoint
//
//  Created by Luis Padron on 1/21/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

open class UIHandlerButton: UIButton {
    
    // MARK: Properties
    
    /// Typealias for the button handler
    public typealias ButtonHandler = () -> Void
    /// The handler for the button, gets called when touch events are found
    private var handler: ButtonHandler?
    
    // MARK: Initializers
    
    required public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not set up")
    }
    
    // MARK: Targets
    
    public func addHandler(controlEvents events: UIControlEvents, handler: @escaping ButtonHandler) {
        self.handler = handler
        self.addTarget(self, action: #selector(self.handleTouches), for: events)
    }
    
    @objc private func handleTouches() {
        // Call the handler
        guard let h = self.handler else {
            return
        }
        
        h()
    }
}
