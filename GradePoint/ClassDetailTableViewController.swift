//
//  ClassDetailTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 7/17/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

class ClassDetailTableViewController: UITableViewController {

    // MARK: Properties

    /// The public class object that is set when presenting this view controller
    public var classObj: Class?

    /// The private class object which makes sure to check for invalidation, which SHOULD only
    /// be used while inside this controller
    private var _classObj: Class?

    // MARK: View Handleing Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: Table View Methods

    /// MARK: Helper Methods

    public func updateUIForClassChanges() {

    }
}

