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

    var preferedSnackbarBottomSpacing: CGFloat {
        return self.tabBarController!.tabBar.frame.height + 12
    }

    // MARK: Subviews

    /// The progress ring view which displays the score for the current class
    @IBOutlet var progressRing: UICircularProgressRing!

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
    
    /// The class listener responsible for listening to any updates that modifies the class object
    /// that this controller relies on. For example, will call modify when a new assignment is added to the class.
    public weak var classListener: ClassChangesListener? = nil

    // MARK: View handling

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the progressRing as the tableHeaderView, encapsulates the view to stop clipping
        let encapsulationView = UIView() //
        encapsulationView.addSubview(progressRing)
        self.tableView.tableHeaderView = encapsulationView

        // Remove seperator lines from empty cells
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        // Setup tableview estimates
        self.tableView.estimatedRowHeight = 75
        self.tableView.estimatedSectionHeaderHeight = 44
        self.tableView.estimatedSectionFooterHeight = 0

        // Listen for theme changes
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUIForThemeChanges(notification:)),
                                               name: kThemeUpdatedNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI()
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateProgressRing()
        self.setNeedsStatusBarAppearanceUpdate()
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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ApplicationTheme.shared.statusBarStyle
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let rubric = _classObj?.rubrics[section] else { return nil }
        let view = ClassCellHeaderView()
        view.setLabels(title: rubric.name, score: _classObj?.relativeScore(for: rubric))
        return view
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let assignment = self.assignment(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentCell", for: indexPath) as! AssignmentTableViewCell

        cell.nameLabel.text = assignment.name
        let decimalPlaces = UserDefaults.standard.integer(forKey: kUserDefaultDecimalPlaces)
        cell.scoreLabel.text = String(format: "Score: %.\(decimalPlaces)f", assignment.percentage) + "%"
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        cell.dateLabel.text = "Date: " + formatter.string(from: assignment.date)

        cell.nameLabel.textColor = ApplicationTheme.shared.mainTextColor()
        cell.scoreLabel.textColor = ApplicationTheme.shared.secondaryTextColor()
        cell.dateLabel.textColor = ApplicationTheme.shared.secondaryTextColor()

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
        self.view.backgroundColor = ApplicationTheme.shared.backgroundColor


        // custom progress ring styles

        self.progressRing.fontColor = ApplicationTheme.shared.mainTextColor()
        self.progressRing.font = UIFont.systemFont(ofSize: 40)
        self.progressRing.style = .ontop
        let roundingAmount = UserDefaults.standard.integer(forKey: kUserDefaultDecimalPlaces)
        self.progressRing.valueFormatter = UICircularProgressRingFormatter(showFloatingPoint: true,
                                                                           decimalPlaces: roundingAmount)

        if let color = self._classObj?.color {
            self.progressRing.innerRingColor = color
            switch ApplicationTheme.shared.theme {
            case .dark: self.progressRing.outerRingColor = ApplicationTheme.shared.backgroundColor.lighter(by: 20) ?? ApplicationTheme.shared.backgroundColor
            case .light, .eco, .purple:
                self.progressRing.outerRingColor = ApplicationTheme.shared.lightBackgroundColor.darker(by: 25) ??
                    ApplicationTheme.shared.lightBackgroundColor
            }

            let gradientColors = [color.lighter(by: 40) ?? color, color, color.darker(by: 30) ?? color]
            self.progressRing.gradientOptions = UICircularRingGradientOptions(startPosition: .topRight,
                                                                              endPosition: .bottomLeft,
                                                                              colors: gradientColors,
                                                                              colorLocations: [0, 0.5, 1])
        }

        self.tableView.scrollsToTop = true
        self.tableView.separatorColor = ApplicationTheme.shared.tableViewSeperatorColor
        
        if let classObj = _classObj {
            self.title = classObj.name
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.title = nil
            self.progressRing.isHidden = true
            self.progressRing.superview?.isHidden = true
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.tableView.reloadData()
        }
    }

    /// Updates the progress on the progress ring
    private func updateProgressRing() {
        guard let classObj = _classObj else { return }
        self.progressRing.startProgress(to: Class.calculateScore(for: assignments, in: classObj), duration: 1.3) {
            // Present rating if possible
            guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
            if RatingManager.shouldPresentRating(appInfo: delegate.appInfo) {
                RatingManager.presentRating()
            }
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
        let section = indexOf(rubric: assign.rubric!)!
        self.deleteCellWithObject(assign, section: section,
                                  snackTitle: "Assignment deleted", buttonTitle: "UNDO",
                                  allowsUndo: true)
        { (undone, assignment) in
            if !undone {
                DatabaseManager.shared.deleteObjects([assignment])
                // Reload section to update relative score label, etc.
                self.tableView.beginUpdates()
                self.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
                self.tableView.endUpdates()
                // Notify listener that underlying class has been modified
                if let modifiedClass = self._classObj {
                    self.classListener?.classWasUpdated(modifiedClass)
                }
            }
            self.updateProgressRing()
        }

        self.updateProgressRing()
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

extension ClassDetailTableViewController: AssignmentChangesListener {
    func assignmentWasCreated(_ assignment: Assignment) {
        self.tableView.beginUpdates()
        let section = indexOf(rubric: assignment.rubric!)!
        assignments[section].append(assignment)
        assignments[section] = assignments[section].sorted { $0.date < $1.date }
        let row = assignments[section].firstIndex(of: assignment)!
        self.tableView.insertRows(at: [IndexPath(row: row, section: section)], with: .automatic)
        self.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        self.tableView.endUpdates()
        self.updateProgressRing()
        
        // Notify listener that underlying class has been modified
        if let modifiedClass = _classObj {
            self.classListener?.classWasUpdated(modifiedClass)
        }
    }

    func assignmentRubricWasUpdated(_ assignment: Assignment, from rubric1: Rubric, to rubric2: Rubric) {
        let fromSection = indexOf(rubric: rubric1)!
        let toSection = indexOf(rubric: rubric2)!

        self.moveCellWithObject(assignment,
                                from: IndexPath(row: assignments[fromSection].firstIndex(of: assignment)!, section: fromSection),
                                to: IndexPath(row: assignments[toSection].count, section: toSection))
        self.tableView.beginUpdates()
        self.tableView.reloadSections(IndexSet(integer: fromSection), with: .automatic)
        self.tableView.reloadSections(IndexSet(integer: toSection), with: .automatic)
        self.tableView.endUpdates()
    }

    func assignmentWasUpdated(_ assignment: Assignment) {
        let section = indexOf(rubric: assignment.rubric!)!
        self.reloadCellWithObject(assignment, section: section)
        self.tableView.beginUpdates()
        self.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        self.tableView.endUpdates()
        self.updateProgressRing()
        // Notify listener that underlying class has been modified
        if let modifiedClass = _classObj {
            self.classListener?.classWasUpdated(modifiedClass)
        }
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

        vc.listener = self

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

        progressRing.fontColor = ApplicationTheme.shared.mainTextColor()
        let val = progressRing.value
        progressRing.resetProgress()
        progressRing.startProgress(to: val, duration: 0)

        self.tableView.reloadData()
    }
}

