//
//  GradePercentagesTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 5/4/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import UIKit

class GradePercentagesTableViewController: UITableViewController {

    /// The rows which will contain any + or - fields
    let plusRows = [0, 2, 3, 5, 6,  8, 9, 11]

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI Setup
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }

        // TableView customization
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = ApplicationTheme.shared.tableViewSeperatorColor
        self.tableView.estimatedRowHeight = 60

        // Add save button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                 target: self,
                                                                 action: #selector(self.onSaveTapped))

    }

    // MARK: - Table view methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }

    // MARK: - Actions

    @objc private func onSaveTapped(button: UIBarButtonItem) {
        
    }
}
