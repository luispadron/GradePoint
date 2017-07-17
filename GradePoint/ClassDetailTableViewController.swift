//
//  ClassDetailTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 7/17/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import UICircularProgressRing

class ClassDetailTableViewController: UITableViewController {

    // MARK: Subviews

    /// The progress ring view which displays the score for the current class
    @IBOutlet var progressRing: UICircularProgressRingView!

    // MARK: Properties

    /// The public class object that is set when presenting this view controller
    public var classObj: Class?

    /// The private class object which makes sure to check for invalidation, which SHOULD only
    /// be used while inside this controller
    private var _classObj: Class?

    // MARK: View Handleing Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the progressRing as the tableHeaderView, encapsulates the view to stop clipping
        let encapsulationView = UIView() //
        encapsulationView.addSubview(progressRing)
        self.tableView.tableHeaderView = encapsulationView

        // Remove seperator lines from empty cells
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

        // Set color for progress ring
        if let color = _classObj?.color {
            self.progressRing.innerRingColor = color
            self.progressRing.outerRingColor = UIColor.background.lighter(by: 20) ?? UIColor.background
            self.progressRing.gradientColors = [color.lighter(by: 40) ?? color,
                                                color,
                                                color.darker(by: 30) ?? color]
        }

        self.progressRing.font = UIFont.systemFont(ofSize: 40)

        self.tableView.scrollsToTop = true

        // Setup tableview estimates
        self.tableView.estimatedRowHeight = 65
        self.tableView.estimatedSectionHeaderHeight = 44
        self.tableView.estimatedSectionFooterHeight = 0
    }

    // MARK: Table View Methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    /// MARK: Helper Methods

    private func updateUI() {

    }

    public func updateUIForClassChanges() {

    }
}

