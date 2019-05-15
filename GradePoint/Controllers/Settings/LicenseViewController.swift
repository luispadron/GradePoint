//
//  LicenseViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 6/23/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

class LicenseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
    }
}
