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

class ClassDetailTableViewController: UITableViewController, RealmTableView {
    // Conformance to RealmTableView protocol
    typealias RealmObject = Assignment
    var realmData: [[Assignment]] {
        get { return assignments }
        set { assignments = newValue }
    }
    private var assignmentDeletionQueue = [Assignment: LPSnackbar]()
    var deletionQueue: [Assignment: LPSnackbar] {
        get { return assignmentDeletionQueue }
        set { assignmentDeletionQueue = newValue }
    }

    // MARK: Subviews

    /// The progress ring view which displays the score for the current class
    @IBOutlet var progressRing: UICircularProgressRingView!

    // MARK: Properties

    /// The public class object that is set when presenting this view controller
    public var classObj: Class? {
        didSet {
            assignments.removeAll()
            loadAssignments()
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
    private var assignments: [[Assignment]] = []

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

        // Update text color
        progressRing.fontColor = UIColor.mainTextColor()

        // Set color for progress ring
        if let color = _classObj?.color {
            progressRing.innerRingColor = color
            switch UIColor.theme {
            case .dark: progressRing.outerRingColor = UIColor.background.lighter(by: 20) ?? UIColor.background
            case .light: progressRing.outerRingColor = UIColor.lightBackground.darker(by: 25) ?? UIColor.lightBackground
            }
            progressRing.gradientColors = [color.lighter(by: 40) ?? color, color, color.darker(by: 30) ?? color]
        }

        progressRing.font = UIFont.systemFont(ofSize: 40)

        tableView.scrollsToTop = true
        tableView.separatorColor = UIColor.tableViewSeperator

        // Setup tableview estimates
        tableView.estimatedRowHeight = 75
        tableView.estimatedSectionHeaderHeight = 44
        tableView.estimatedSectionFooterHeight = 0

        // Listen for them changes
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUIForThemeChanges(notification:)),
                                               name: themeUpdatedNotification, object: nil)
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dequeAndDeleteObjects()
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
        header.textLabel?.textColor = UIColor.tableViewHeaderText
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let assignment = self.assignment(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentCell", for: indexPath) as! AssignmentTableViewCell

        cell.nameLabel.text = assignment.name
        cell.scoreLabel.text = "Score: \(assignment.score)%"
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        cell.dateLabel.text = "Date: " + formatter.string(from: assignment.date)

        cell.nameLabel.textColor = UIColor.mainTextColor()
        cell.scoreLabel.textColor = UIColor.secondaryTextColor()
        cell.dateLabel.textColor = UIColor.secondaryTextColor()

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
            assignments.append(Array(grouped))
        }
    }

    /// Returns an Assignment at the specified index path
    private func assignment(at path: IndexPath) -> Assignment {
        return assignments[path.section][path.row]
    }

    /// Updates the UI
    private func updateUI() {
        self.view.backgroundColor = UIColor.background
        self.tableView.separatorColor = UIColor.tableViewSeperator
        if let classObj = _classObj {
            title = classObj.name
            navigationItem.leftBarButtonItem?.isEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            title = nil
            progressRing.isHidden = true
            self.progressRing.superview?.isHidden = true
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false
            tableView.reloadData()
            self.reloadEmptyState()
        }
    }

    /// Updates the progress on the progress ring
    private func updateProgressRing() {
        guard let classObj = _classObj else { return }
        if !progressRing.isAnimating {
            progressRing.setProgress(value: Class.calculateScore(for: assignments, in: classObj), animationDuration: 1.3)
        }
    }

    // For some reason index(of:) in collection when rubric is copied isn't working correctly so manual loop is required
    // TODO: Remove this code when Swift is fixed??
    private func indexOf(rubric: Rubric) -> Int? {
        guard let rubrics = _classObj?.rubrics else { return nil }

        for (i, r) in rubrics.enumerated() {
            if r == rubric { return i }
        }

        return nil
    }

    /// Handles deleting an Assignment at the specified IndexPath
    private func handleDelete(at path: IndexPath) {
        let assign = assignment(at: path)
        self.deleteCellWithObject(assign, section: indexOf(rubric: assign.rubric!)!,
                                  snackTitle: "Assignment deleted.", buttonTitle: "UNDO",
                                  allowsUndo: true)
        { (undone, assignment) in
            if !undone {
                DatabaseManager.shared.deleteObjects([assignment])
            }

            self.updateProgressRing()
            self.reloadEmptyState()
        }

        self.updateProgressRing()
        self.reloadEmptyState()
    }
    
    // Conformance to RealmTableView
    func deleteObject(_ object: Assignment) {
        DatabaseManager.shared.deleteObjects([object])
    }
    
    deinit {
        // Remove references
        classObj = nil
        assignments.removeAll()
    }
}

// MARK: AddEditAssignment Delegation

extension ClassDetailTableViewController: AddEditAssignmentDelegate {
    func assignmentWasCreated(_ assignment: Assignment) {
        self.tableView.beginUpdates()
        let section = indexOf(rubric: assignment.rubric!)!
        assignments[section].append(assignment)
        assignments[section] = assignments[section].sorted { $0.date < $1.date }
        let row = assignments[section].index(of: assignment)!
        self.tableView.insertRows(at: [IndexPath(row: row, section: section)], with: .automatic)
        if assignments[section].count == 1 {
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
        self.tableView.endUpdates()
        self.reloadEmptyState()
        self.updateProgressRing()
    }

    func assignmentRubricWasUpdated(_ assignment: Assignment, from rubric1: Rubric, to rubric2: Rubric) {
        let fromSection = indexOf(rubric: rubric1)!
        let toSection = indexOf(rubric: rubric2)!

        self.moveCellWithObject(assignment,
                                from: IndexPath(row: assignments[fromSection].index(of: assignment)!, section: fromSection),
                                to: IndexPath(row: assignments[toSection].count, section: toSection))
    }

    func assignmentWasUpdated(_ assignment: Assignment) {
        self.reloadCellWithObject(assignment, section: indexOf(rubric: assignment.rubric!)!)

        self.updateProgressRing()
    }
}

// MARK: Empty State Delegate & Data Source

extension ClassDetailTableViewController: UIEmptyStateDataSource, UIEmptyStateDelegate {

    // DataSource

    func emptyStateViewShouldShow(for tableView: UITableView) -> Bool {
        return assignments.isTrueEmpty
    }

    var emptyStateTitle: NSAttributedString {
        guard _classObj != nil else { return NSAttributedString(string: "") }
        let attributes: [NSAttributedStringKey : Any] = [.font: UIFont.systemFont(ofSize: 20),
                                                         .foregroundColor: UIColor.mainTextColor()]

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
        self.progressRing.superview?.isHidden = true
        self.progressRing.isHidden = true
    }

    func emptyStateViewWillHide(view: UIView) {
        self.progressRing.isHidden = false
        self.progressRing.superview?.isHidden = false
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

        vc.delegate = self

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

// MARK: Notification Methods

extension ClassDetailTableViewController {
    /// Called whenever the theme is changed, updates any UI that needs to change color, etc.
    @objc func updateUIForThemeChanges(notification: Notification) {

        progressRing.fontColor = UIColor.mainTextColor()
        let val = progressRing.value
        progressRing.setProgress(value: 0, animationDuration: 0)
        progressRing.setProgress(value: val, animationDuration: 0)

        self.tableView.reloadData()
        self.reloadEmptyState()
    }
}

