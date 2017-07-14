//
//  DetailViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 10/12/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift
import UICircularProgressRing
import UIEmptyState
import LPSnackbar

class ClassDetailTableViewController: UITableViewController {

    // MARK: - Properties
    
    /// Outlet for the add button in the navigation controller
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    /// Outlet to the Progress Ring View
    @IBOutlet var progressRing: UICircularProgressRingView!
    
    /// The class object which will be shown as detail, selected from the master controller ClassTableViewController
    var classObj: Class? {
        didSet {
            guard let `classObj` = classObj, !classObj.isInvalidated else {
                rubrics.removeAll()
                assignments.removeAll()
                return
            }
            // Assign the rubrics array
            rubrics = Array(classObj.rubrics)
            // Assign/update the assignments 2D array
            reloadAssignments()
        }
    }
    
    /// The accesor for the class obj, this will check if invalidated in realm or not before returning
    private var _classObj: Class? {
        get {
            guard let obj = self.classObj, !obj.isInvalidated else {
                // Has become invalidated, set classObj to nil
                self.classObj = nil
                return nil
            }
            return obj
        }
    }
    
    /// The rubrics for this class
    var rubrics = [Rubric]()
    
    /// The assignments grouped by rubric
    var assignments = [[Assignment]]()
    
    /// Returns whether or not this is the first time the view was presented
    var isFirstAppearance: Bool = true
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add dataSource and delegate for UIEmptyState
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        
        // Set the progressRing as the tableHeaderView
        let encapsulationView = UIView() // encapsulates the view to stop clipping
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set seperator color
        self.tableView.separatorColor = UIColor.tableViewSeperator
        // Configure the view for load, only initially
        if isFirstAppearance {
            updateUI(shouldCalculateProgress: false) // Dont calculate progress here because too early for animations
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstAppearance {
            updateUI()
            // Only want to update the UI initially. Afterwards, other methods will handle calling for updates
            isFirstAppearance = false
        }
    }
    
    override func viewWillLayoutSubviews() {
        if let headerView = self.tableView.tableHeaderView {
            headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 240)
            progressRing.center = headerView.center
        }
        
        super.viewWillLayoutSubviews()
    }
    
    // MARK: - TableView Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return rubrics.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignments[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(self.tableView, numberOfRowsInSection: section) > 0 ? 44 : 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let rubricForSection = rubrics[section]
        // Create the correct headerView for the section
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 44))
        mainView.backgroundColor = UIColor.tableViewHeader
        
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: mainView.bounds.size.width, height: 44))
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.unselected
        label.backgroundColor = UIColor.tableViewHeader
        mainView.addSubview(label)
        
        // Set the correct label text
        label.text = "\(rubricForSection.name)"
        
        return mainView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let assignmentForRow = assignment(for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "assignmentTableViewCell", for: indexPath) as! AssignmentTableViewCell
        cell.selectionStyle = .default
        cell.nameLabel.text = assignmentForRow.name
        cell.scoreLabel.text = "Score: \(assignmentForRow.score.roundedUpTo(2))%"
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        cell.dateLabel.text = "Date: " + formatter.string(from: assignmentForRow.date)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: .editAssignment, sender: tableView.cellForRow(at: indexPath)!)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Delete Action
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { [weak self] action, indexPath in
            self?.deleteAssignment(at: indexPath)
        })
        
        deleteAction.backgroundColor = .warning
    
        return [deleteAction]
    }
    
    // MARK: - Helpers
    
    /// Reloads and updates the `assignments` array
    private func reloadAssignments() {
        guard let classObj = _classObj else {
            print("Unable to reload assignments, no value for `_classObj`")
            return
        }
        
        var arr = [[Assignment]]()
        rubrics.forEach {
            let groupedAssignments = classObj.assignments.filter("associatedRubric = %@", $0).sorted(byKeyPath: "date",
                                                                                                     ascending: true)
            arr.append(Array(groupedAssignments))
        }
        
        // Assign the assignments array
        assignments = arr
    }
    
    /// Configures the view depending on if we have a detail item (classObj) or not
    private func updateUI(shouldCalculateProgress: Bool = true) {
        self.title = self._classObj?.name
        self.addButton.isEnabled = self._classObj != nil
        self.splitViewController?.displayModeButtonItem.isEnabled = self._classObj != nil
        self.reloadEmptyState()
        if shouldCalculateProgress { self.calculateProgress() }
    }
    
    /// Updates the UI so that any changes to a related class will affect this view
    /// This is called when a class is deleted inside of ClassesTableViewController
    public func updateUIForClassChanges() {
        // Update table view
        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        self.reloadEmptyState()
        
        // Update title and buttons
        self.title = self._classObj?.name
        self.addButton.isEnabled = self._classObj != nil
        self.splitViewController?.displayModeButtonItem.isEnabled = self._classObj != nil
        
    }
    
    /// Calculates the percentage for the progress ring
    func calculateProgress() {
        guard let classObj = _classObj else { return }
        self.progressRing.setProgress(value: Class.calculateScore(for: assignments, in: classObj), animationDuration: 1.5)
    }
    
    func assignment(for indexPath: IndexPath) -> Assignment {
        return assignments[indexPath.section][indexPath.row]
    }
    
    func deleteAssignment(at indexPath: IndexPath) {
        let assignment = self.assignment(for: indexPath)
        
        // Remove from array, but dont delete from Realm yet since user may undo
        assignments[indexPath.section].remove(at: indexPath.row)
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .left)
        self.tableView.reloadSections(IndexSet.init(integer: indexPath.section), with: .fade)
        self.tableView.endUpdates()
        self.reloadEmptyState()
        
        calculateProgress()
        
        // Present snackbar with undo option
        let snack = LPSnackbar(title: "Assignment deleted.", buttonTitle: "UNDO")
        snack.show(animated: true) { [weak self] (undone) in
            if undone {
                guard let count = self?.assignments[indexPath.section].count else { return }
                // Re-add to array and reload tableview
                self?.tableView.beginUpdates()
                if indexPath.row > count {
                    self?.assignments[indexPath.section].append(assignment)
                    self?.tableView.insertRows(at: [IndexPath(row: count - 1, section: indexPath.section)], with: .automatic)
                    self?.tableView.reloadSections(IndexSet.init(integer: indexPath.section), with: .fade)
                } else {
                    self?.assignments[indexPath.section].insert(assignment, at: indexPath.row)
                    self?.tableView.insertRows(at: [indexPath], with: .automatic)
                    self?.tableView.reloadSections(IndexSet.init(integer: indexPath.section), with: .fade)
                    
                }
                self?.tableView.endUpdates()
                self?.reloadEmptyState()
                self?.calculateProgress()
            } else {
                // Remove from Realm finally
                DatabaseManager.shared.deleteObjects([assignment])
            }
        }
    }
    
    deinit {
        self.classObj = nil
    }
}

// MARK: - UIEmptyState DataSource & Delegate

extension ClassDetailTableViewController: UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    // DataSource

    func shouldShowEmptyStateView(forTableView tableView: UITableView) -> Bool {
        return assignments.isTrueEmpty
    }
    
    var emptyStateTitle: NSAttributedString {
        guard let _ = self._classObj else { return NSAttributedString(string: "") }
        // Attributes for the attributed string
        let attributes: [NSAttributedStringKey : Any] = [.font: UIFont.systemFont(ofSize: 20),
                                                         .foregroundColor: UIColor.mainText]
        return NSAttributedString(string: "No assignments added", attributes: attributes)
    }
    
    var emptyStateButtonTitle: NSAttributedString? {
        // If no class selected, or if class is a previous class, then dont show the button
        guard let _ = self._classObj else { return nil }
        
        let attrs: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.accentGreen,
                                                   .font: UIFont.systemFont(ofSize: 18)]
        return NSAttributedString(string: "Add assignment", attributes: attrs)
    }
    
    var emptyStateButtonImage: UIImage? {
        // If no class selected, or if class is a previous class, then dont show the button image
        guard let _ = self._classObj else { return nil }
        
        return #imageLiteral(resourceName: "ButtonBg")
    }
    
    var emptyStateButtonSize: CGSize? {
        // If no class selected, or if class is a previous class, then dont return button size
        guard let _ = self._classObj else { return nil }
        
        return CGSize(width: 170, height: 50)
    }
    
    var emptyStateViewAnimatesEverytime: Bool { return false }
    
    var emptyStateViewAnimationDuration: TimeInterval { return 0.8 }
    
    // Delegate
    
    func emptyStateViewWillShow(view: UIView) {
        // Hide the progress ring
        self.progressRing.isHidden = true
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false
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

// MARK: - Segues

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
            vc.parentClass = self._classObj
            vc.delegate = self
            
        case .editAssignment:
            guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else { return }
            // Prepare view for segue
            let nav = segue.destination
            nav.popoverPresentationController?.barButtonItem = addButton
            let screenSize = UIScreen.main.bounds.size
            nav.preferredContentSize = CGSize(width: screenSize.width / 2, height: screenSize.height / 2)
            
            let vc = (segue.destination as! UINavigationController).topViewController as! AddEditAssignmentTableViewController
            vc.parentClass = self._classObj
            vc.delegate = self
            vc.assignmentForEdit = self.assignment(for: indexPath)
        }
    }
}


// MARK: - AddEditAssignmentViewDelegate

extension ClassDetailTableViewController: AddEditAssignmentViewDelegate {
    func didFinishCreating(assignment: Assignment) {
        // Reload assignments, to get new object that was created
        reloadAssignments()
        
        guard let section = rubrics.index(of: assignment.associatedRubric!),
            let row = assignments[section].index(of: assignment) else
        {
            print("WARNING: Could not find section or row for created assignment")
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            return
        }
        
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: row, section: section)], with: .right)
        self.tableView.reloadSections(IndexSet.init(integer: section), with: .fade)
        self.tableView.endUpdates()
        self.tableView.layoutIfNeeded()
        
        self.updateUI()
        
        // Now that user has added a class, and hopefully enjoyed it, ask them to rate if possible
        RatingManager.presentRating()
    }
    
    func didFinishUpdating(assignment: Assignment) {
        self.tableView.reloadData()
        self.updateUI()
    }
}
