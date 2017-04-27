//
//  UISegmentedControl+ViewState.swift
//  GradePoint
//
//  Created by Luis Padron on 4/27/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

extension UISegmentedControl {
    var selectedState: ViewState {
        return self.selectedSegmentIndex == 0 ? .inProgress : .past
    }
}
