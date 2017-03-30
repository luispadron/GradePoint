//
//  Segueable.swift
//  GradePoint
//
//  Created by Luis Padron on 1/29/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

protocol Segueable {
    associatedtype SegueIdentifier: RawRepresentable
}

extension Segueable where Self: UIViewController, SegueIdentifier.RawValue == String {
    /// Performs a segue given the identifier
    func performSegue(withIdentifier identifier: SegueIdentifier, sender: AnyObject?) {
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
    
    /// Returns a segue identifier for the specified segue
    func segueIdentifier(forSegue segue: UIStoryboardSegue) -> SegueIdentifier {
        guard let identifier = segue.identifier, let segueIdentifer = SegueIdentifier(rawValue: identifier) else {
            fatalError("Invalid segue identfier \(String(describing: segue.identifier))")
        }
        
        return segueIdentifer
    }
}
