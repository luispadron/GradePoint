//
//  GradePercentagesTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 5/4/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

class GradePercentagesTableViewController: UITableViewController {

    /// The rows which will contain any + or - fields
    private let plusRows = [0, 2, 3, 5, 6,  8, 9, 11]

    /// The realm notifcation token for listening to changes on the GPAScale
    private var notifToken: NotificationToken?

    /// The grade percentage views, 1 per cell that the table statically displays
    @IBOutlet var percentageViews: [UIGradePercentageView]!

    // The header view for the table, displays an info message to the user with a reset button in the middle
    @IBOutlet var headerView: UIView!
    
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

        // Update headerview style
        (self.headerView.subviews[0] as! UILabel).textColor = ApplicationTheme.shared.mainTextColor()
        (self.headerView.subviews[1] as! UIButton).setTitleColor(ApplicationTheme.shared.highlightColor, for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Initialize all the grade percentage views
        self.updateFields()

        // Add header view
        self.tableView.tableHeaderView = self.headerView
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }

    // MARK: - Table view methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if GPAScale.shared.scaleType == .nonPlusScale && plusRows.contains(indexPath.row) { return 0 }
        else { return 60 }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 13
    }

    // MARK: - Actions

    @objc private func onSaveTapped(button: UIBarButtonItem) {
        guard let newPercentages = self.verifyPercentages() else { return }

        let title = NSAttributedString(string: "Save Percentages")
        let msg = NSAttributedString(string: "Are you sure you want to save percentages? If done incorrectly this can lead to undefined behavior")
        let alert = UIBlurAlertController(size: CGSize(width: 300, height: 200), title: title, message: msg)

        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = .info

        alert.addButton(button: cancelButton, handler: nil)

        let resetButton = UIButton(type: .custom)
        resetButton.setTitle("Save", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.backgroundColor = .warning

        alert.addButton(button: resetButton, handler: { [weak self] in
            self?.savePercentages(newPercentages)
        })

        alert.presentAlert(presentingViewController: self)
    }

    @IBAction func resetButtonTapped(_ sender: UIButton) {
        let title = NSAttributedString(string: "Reset To Default")
        let msg = NSAttributedString(string: "Are you sure you want to reset to default? This cant be undone")
        let alert = UIBlurAlertController(size: CGSize(width: 300, height: 200), title: title, message: msg)

        let cancelButton = UIButton(type: .custom)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.backgroundColor = .info

        alert.addButton(button: cancelButton, handler: nil)

        let resetButton = UIButton(type: .custom)
        resetButton.setTitle("Reset", for: .normal)
        resetButton.setTitleColor(.white, for: .normal)
        resetButton.backgroundColor = .warning

        alert.addButton(button: resetButton, handler: self.resetPercentages)

        alert.presentAlert(presentingViewController: self)
    }

    // MARK: - Heleprs

    private func updateFields() {
        // Disable the upperbound field of the A+ or A since the upperbound is anything greater than lowerbound
        switch GPAScale.shared.scaleType {
        case .plusScale:
            percentageViews.first?.upperLowerMode = false
        case .nonPlusScale:
            percentageViews[1].upperLowerMode = false
        }

        var rangeIndex = 0
        for (index, view) in percentageViews.enumerated() {
            view.lowerBoundField.font = UIFont.systemFont(ofSize: 18)
            view.upperBoundField.font = UIFont.systemFont(ofSize: 18)
            view.lowerBoundField.tintColor = ApplicationTheme.shared.highlightColor
            view.upperBoundField.tintColor = ApplicationTheme.shared.highlightColor
            view.lowerBoundField.textColor = ApplicationTheme.shared.highlightColor
            view.upperBoundField.textColor = ApplicationTheme.shared.highlightColor

            let attrs = [NSAttributedStringKey.foregroundColor: ApplicationTheme.shared.secondaryTextColor(),
                         NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)]

            if GPAScale.shared.scaleType == .nonPlusScale && self.plusRows.contains(index) { continue }

            if rangeIndex == 0 {
                view.lowerBoundField.attributedPlaceholder = NSAttributedString(string: "\(GradeRubric.shared.percentage(for: rangeIndex, type: .lowerBound))% +", attributes: attrs)
            } else {
                view.lowerBoundField.attributedPlaceholder = NSAttributedString(string: "\(GradeRubric.shared.percentage(for: rangeIndex, type: .lowerBound))%", attributes: attrs)
            }

            view.upperBoundField.attributedPlaceholder = NSAttributedString(string: "\(GradeRubric.shared.percentage(for: rangeIndex, type: .upperBound))%", attributes: attrs)
            rangeIndex += 1
        }
    }

    private func resetFields() {
        for view in self.percentageViews {
            view.lowerBoundField.text = nil
            view.upperBoundField.text = nil
        }
    }

    /// Recalculates all grades associated with all class objects in Realm
    /// Called after reset/save
    private func recalculateGradesForClasses() {
        let classes = DatabaseManager.shared.realm.objects(Class.self)
        DatabaseManager.shared.write {
            for classObj in classes.filter({ $0.isInProgress }) {
                classObj.grade?.gradeLetter = Grade.gradeLetter(for: classObj.grade!.score)
            }
        }
    }

    private func resetPercentages() {
        GradeRubric.createRubric(ofType: GPAScale.shared.scaleType)

        self.recalculateGradesForClasses()

        self.resetFields()
        self.updateFields()
    }

    private func verifyPercentages() -> [ClosedRange<Double>]? {
        let percentages = DatabaseManager.shared.realm.objects(GradePercentage.self)
        var newPercentages = [ClosedRange<Double>]()

        // Verify that all ranges are valid
        var percentIndex = 0
        for (index, view) in self.percentageViews.enumerated() {
            if GPAScale.shared.scaleType == .nonPlusScale && self.plusRows.contains(index) { continue }

            var newLowerBound: Double = percentages[percentIndex].lowerBound
            var newUpperBound: Double = percentages[percentIndex].upperBound

            if view.lowerBoundField.safeText.isValid() {
                newLowerBound = Double(view.lowerBoundField.safeText)!
            }

            if view.upperBoundField.safeText.isValid() {
                newUpperBound = Double(view.upperBoundField.safeText)!
            }

            if newLowerBound >= newUpperBound {
                self.presentErrorAlert(title: "Error Saving 💔", message: "Lower bound for grade #\(percentIndex + 1) must be less than upper bound")
                return nil
            }

            newPercentages.append(newLowerBound...newUpperBound)
            percentIndex += 1
        }

        return newPercentages
    }

    /// Saves the results of percentage changes by updating percentage objects and recalculating grades for classes
    private func savePercentages(_ newPercentages: [ClosedRange<Double>]) {
        let percentages = DatabaseManager.shared.realm.objects(GradePercentage.self)

        DatabaseManager.shared.write {
            for (index, newPercentage) in newPercentages.enumerated() {
                percentages[index].lowerBound = newPercentage.lowerBound
                percentages[index].upperBound = newPercentage.upperBound
            }
        }

        self.recalculateGradesForClasses()

        self.resetFields()
        self.updateFields()
    }
}
