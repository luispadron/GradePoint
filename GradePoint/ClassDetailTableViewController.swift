//
//  ClassDetailTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 7/17/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift
import UIEmptyState
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

        emptyStateDelegate = self
        emptyStateDataSource = self

        // Set the progressRing as the tableHeaderView, encapsulates the view to stop clipping
        let encapsulationView = UIView() //
        encapsulationView.addSubview(progressRing)
        tableView.tableHeaderView = encapsulationView

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
        tableView.estimatedRowHeight = 75
        tableView.estimatedSectionHeaderHeight = 44
        tableView.estimatedSectionFooterHeight = 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateUI()
        reloadEmptyState()
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateProgressRing()
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.tintColor = UIColor.tableViewHeader
        header.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
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
            let grouped = classObj.assignments.filter("rubric = %@", $0).sorted(byKeyPath: "date", ascending: true)
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
                self?.updateProgressRing()
                self?.reloadEmptyState()

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

    /// Updates the progress on the progress ring
    private func updateProgressRing() {
        guard let classObj = _classObj else { return }
        if !progressRing.isAnimating {
            progressRing.setProgress(value: Class.calculateScore(for: assignments, in: classObj), animationDuration: 1.3)
        }
    }

    /// Handles deleting an Assignment at the specified IndexPath
    private func handleDelete(at path: IndexPath) {
        guard let classObj = _classObj else { return }
        let assignment = self.assignment(at: path)
        let rubric = assignment.rubric
        // Keep copy in case user undoes deletion
        let copy = assignment.copy() as! Assignment
        // Set rubric to same reference after copying assignment
        copy.rubric = rubric

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
            DatabaseManager.shared.write {
                classObj.assignments.append(copy)
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

// MARK: Empty State Delegate & Data Source

extension ClassDetailTableViewController: UIEmptyStateDataSource, UIEmptyStateDelegate {

    // DataSource

    func shouldShowEmptyStateView(forTableView tableView: UITableView) -> Bool {
        return assignments.isTrueEmpty
    }

    var emptyStateTitle: NSAttributedString {
        guard _classObj != nil else { return NSAttributedString(string: "") }
        let attributes: [NSAttributedStringKey : Any] = [.font: UIFont.systemFont(ofSize: 20),
                                                         .foregroundColor: UIColor.mainTextColor(in: UIColor.theme)]

        return NSAttributedString(string: "No assignments added", attributes: attributes)
    }

    var emptyStateButtonTitle: NSAttributedString? {
        guard _classObj != nil else { return nil }
        let attrs: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.highlight,
                                                   .font: UIFont.systemFont(ofSize: 18)]

        return NSAttributedString(string: "Add assignment", attributes: attrs)
    }

    var emptyStateButtonImage: UIImage? {
        // If no class selected, or if class is a previous class, then dont show the button image
        guard _classObj != nil else { return nil }

        return #imageLiteral(resourceName: "ButtonBg")
    }

    var emptyStateButtonSize: CGSize? {
        // If no class selected, or if class is a previous class, then dont return button size
        guard _classObj != nil else { return nil }

        return CGSize(width: 170, height: 50)
    }

    var emptyStateViewAnimatesEverytime: Bool { return false }

    var emptyStateViewAnimationDuration: TimeInterval { return 0.8 }

    // Delegate

    func emptyStateViewWillShow(view: UIView) {
        guard let emptyView = view as? UIEmptyStateView else { return }

        // Update tint for button
        emptyView.button.tintColor = .highlight

        // Hide the progress ring
        self.progressRing.isHidden = true
    }

    func emptyStateViewWillHide(view: UIView) {
        self.progressRing.isHidden = false
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.navigationItem.leftBarButtonItem?.isEnabled = true
    }

    func emptyStatebuttonWasTapped(button: UIButton) {
        self.performSegue(withIdentifier: .addAssignment, sender: button)
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
        // Prepare view for segue
        let nav = segue.destination
        let screenSize = UIScreen.main.bounds.size
        let vc = (segue.destination as! UINavigationController).topViewController as! AddEditAssignmentTableViewController
        // Set correct size
        if UIDevice.current.userInterfaceIdiom == .pad {
            nav.preferredContentSize = CGSize(width: screenSize.width / 2, height: screenSize.height / 2)
        } else {
            nav.preferredContentSize = CGSize(width: screenSize.width * 0.65, height: screenSize.height * 0.85)
        }

        switch segueIdentifier(forSegue: segue) {
        case .addAssignment:
            vc.parentClass = _classObj

        case .editAssignment:
            guard let indexPath = sender as? IndexPath else { return }
            vc.parentClass = _classObj
            vc.assignmentForEdit = assignment(at: indexPath)
        }

    }
}

