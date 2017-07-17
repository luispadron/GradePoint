//
//  ClassDetailTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 7/17/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift
import UICircularProgressRing
import LPSnackbar

class ClassDetailTableViewController: UITableViewController {

    // MARK: Subviews

    /// The progress ring view which displays the score for the current class
    @IBOutlet var progressRing: UICircularProgressRingView!

    // MARK: Properties

    /// The public class object that is set when presenting this view controller
    public var classObj: Class? {
        didSet {
            assignments.removeAll()
            loadAssignments()
            // Remove any active notifications
            notificationTokens.forEach { $0.stop() }
            notificationTokens.removeAll()
            // Register notifications now that assignments are set
            for (i, results) in assignments.enumerated() {
                registerNotifications(for: results, in: i)
            }
            // Update the UI
            updateUI()
        }
    }

    /// The private SAFE class object which makes sure to check for invalidation, which SHOULD only
    /// be used while inside this controller
    private var _classObj: Class? {
        guard let valid = classObj, !valid.isInvalidated else { return nil }
        return valid
    }

    /// The assignments from Realm, grouped by their Rubric
    private var assignments: [Results<Assignment>] = [Results<Assignment>]()

    /// All the currently active notification tokens
    private var notificationTokens: [NotificationToken] = [NotificationToken]()

    // MARK: View Handleing Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the progressRing as the tableHeaderView, encapsulates the view to stop clipping
        let encapsulationView = UIView() //
        encapsulationView.addSubview(progressRing)
//        tableView.tableHeaderView = encapsulationView

        // Remove seperator lines from empty cells
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        // Set color for progress ring
        if let color = _classObj?.color {
            progressRing.innerRingColor = color
            progressRing.outerRingColor = UIColor.background.lighter(by: 20) ?? UIColor.background
            progressRing.gradientColors = [color.lighter(by: 40) ?? color, color, color.darker(by: 30) ?? color]
        }

        progressRing.font = UIFont.systemFont(ofSize: 40)

        tableView.scrollsToTop = true
        tableView.separatorColor = UIColor.tableViewSeperator

        // Setup tableview estimates
        tableView.estimatedRowHeight = 65
        tableView.estimatedSectionHeaderHeight = 44
        tableView.estimatedSectionFooterHeight = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateUI()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // Layout the progress ring
        if let headerView = self.tableView.tableHeaderView {
            headerView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 240)
            progressRing.center = headerView.center
        }
    }

    // MARK: Table View Methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return assignments.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignments[section].count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return assignments[section].count > 0 ? 44 : 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return _classObj?.rubrics[section].name ?? nil
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.tintColor = UIColor.tableViewHeader
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        header.textLabel?.textColor = UIColor.unselected
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let assignment = self.assignment(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentCell", for: indexPath) as! AssignmentTableViewCell

        cell.nameLabel.text = assignment.name
        cell.scoreLabel.text = "Score: \(assignment.score)"
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        cell.dateLabel.text = "Date: " + formatter.string(from: assignment.date)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: .editAssignment, sender: indexPath)
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (_, indexPath) in
            self?.handleDelete(at: indexPath)
            DispatchQueue.main.async {
                self?.setEditing(false, animated: true)
            }
        }

        return [delete]
    }

    // MARK: Helper Methods

    /// Loads all assignments into the `assignments` array, called whenever a `classObj` is set
    private func loadAssignments() {
        guard let classObj = _classObj else { return }
        classObj.rubrics.forEach {
            let grouped = classObj.assignments.filter("associatedRubric = %@", $0).sorted(byKeyPath: "date", ascending: true)
            assignments.append(grouped)
        }
    }

    /// Registers all Realm notifications for the `assigments`
    private func registerNotifications(for results: Results<Assignment>, in section: Int) {
        let notification = results.addNotificationBlock { [weak self] (changes) in
            guard let tableView = self?.tableView else { return }

            // Upate table view for any changes
            switch changes {
            case .initial: tableView.reloadData()

            case .update(let results, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: section) }, with: .automatic)
                tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: section)}, with: .automatic)
                tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: section) }, with: .automatic)
                // If this section had no cells previously, reload the section as well
                if results.count - insertions.count == 0 {
                    tableView.reloadSections(IndexSet(integer: section), with: .automatic)
                }
                tableView.endUpdates()

            case .error(let error): fatalError("Error in Realm notification changes.\n\(error)")
            }
        }

        notificationTokens.append(notification)
    }

    /// Returns an Assignment at the specified index path
    private func assignment(at path: IndexPath) -> Assignment {
        return assignments[path.section][path.row]
    }

    /// Updates the UI
    private func updateUI() {
        if let classObj = _classObj {
            title = classObj.name
            navigationItem.leftBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            title = nil
            progressRing.isHidden = true
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
            tableView.reloadData()
        }
    }

    /// Handles deleting an Assignment at the specified IndexPath
    private func handleDelete(at path: IndexPath) {
        guard let classObj = _classObj else { return }
        let assignment = self.assignment(at: path)
        let rubric = assignment.associatedRubric
        // Keep copy in case user undoes deletion
        let copy = assignment.copy() as! Assignment
        // Set rubric to same reference after copying assignment
        copy.associatedRubric = rubric

        // Remove from Realm
        DatabaseManager.shared.deleteObjects([assignment])

        // Present snack to allow user to undo deletion
        let snack = LPSnackbar(title: "Assignment deleted.", buttonTitle: "UNDO", displayDuration: 3.0)
        snack.viewToDisplayIn = navigationController?.view
        snack.bottomSpacing = (tabBarController?.tabBar.frame.height ?? 0) + 12

        snack.show() { undone in
            guard undone else { return }
            // Re-add assignment into Realm
            DatabaseManager.shared.addObject(copy)
            // Re-associate the assignment to the class
            if DatabaseManager.shared.realm.isInWriteTransaction {
                classObj.assignments.append(copy)
            } else {
                try! DatabaseManager.shared.realm.write {
                    classObj.assignments.append(copy)
                }
            }
        }
    }

    deinit {
        // Stop all notifications
        notificationTokens.forEach { $0.stop() }
        // Remove references
        classObj = nil
        assignments.removeAll()
    }
}

// MARK: Segueable Protocol

extension ClassDetailTableViewController: Segueable {
    /// Conformace to Segueable
    enum SegueIdentifier: String {
        case addAssignment = "addAssignment"
        case editAssignment = "editAssignment"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(forSegue: segue) {
        case .addAssignment:
            // Prepare view for segue
            let nav = segue.destination
            let screenSize = UIScreen.main.bounds.size
            nav.preferredContentSize = CGSize(width: screenSize.width / 2, height: screenSize.height / 2)

            let vc = (segue.destination as! UINavigationController).topViewController as! AddEditAssignmentTableViewController
            vc.parentClass = _classObj

        case .editAssignment:
            guard let indexPath = sender as? IndexPath else { return }
            // Prepare view for segue
            let nav = segue.destination
            let screenSize = UIScreen.main.bounds.size
            nav.preferredContentSize = CGSize(width: screenSize.width / 2, height: screenSize.height / 2)

            let vc = (segue.destination as! UINavigationController).topViewController as! AddEditAssignmentTableViewController
            vc.parentClass = _classObj
            vc.assignmentForEdit = assignment(at: indexPath)
        }

    }
}

