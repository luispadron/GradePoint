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

class ClassDetailTableViewController: UITableViewController {

    // MARK: - Properties
    
    /// Realm database
    var realm = try! Realm()
    
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
            rubrics = Array(classObj.rubrics)
            // Set up the assignments array, sorted by its associated rubric
            assignments.removeAll()
            for rubric in rubrics {
                let assignmentsForRubric = classObj.assignments.filter("associatedRubric = %@", rubric)
                assignments.append(assignmentsForRubric)
            }
        }
    }
    
    /// The rubrics for this class
    var rubrics = [Rubric]()
    /// The assignments sorted by rubric
    var assignments = [Results<Assignment>]()
    
    /// If no classes, then this controller should be blank and no interaction should be allowed.
    /// The view and what to display is handled inside the UIEmptyStateDataSource methods
    var shouldShowBlank: Bool { get { return try! Realm().objects(Class.self).count == 0 } }
    
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set seperator color
        self.tableView.separatorColor = UIColor.tableViewSeperator
        // Configure the view for load
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Set progress ring calculation
        self.calculateProgress()
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
        
        cell.nameLabel.text = assignmentForRow.name
        cell.scoreLabel.text = "Score: \(assignmentForRow.score)"
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        cell.dateLabel.text = "Date: " + formatter.string(from: assignmentForRow.date)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // Delete Action
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { [weak self] action, indexPath in
            self?.deleteAssignment(at: indexPath)
        })
        
        deleteAction.backgroundColor = .sunsetOrange
        
        // Edit Action
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { [weak self] action, indexPath in
            // Send the assignment as the sender, since it will be used to edit
            guard let `self` = self else { return }
            let assignmentToEdit = self.assignment(for: indexPath)
            self.performSegue(withIdentifier: .addEditAssignment, sender: assignmentToEdit)
        }
        
        editAction.backgroundColor = .lapisLazuli
        
        return [deleteAction, editAction]
    }
    
    // MARK: - Helpers
    
    /// Configures the view depending on if we have a detail item (classObj) or not
    func configureView() {
        self.tableView.reloadData()
        self.tableView.layoutIfNeeded()
        
        if let classObj = self.classObj {
            self.title = classObj.name
            self.addButton.isEnabled = true
            self.splitViewController?.displayModeButtonItem.isEnabled = true
        } else if shouldShowBlank {
            self.title = nil
            self.addButton.isEnabled = false
            self.splitViewController?.displayModeButtonItem.isEnabled = false
        } else {
            self.title = nil
            self.addButton.isEnabled = false
            self.splitViewController?.displayModeButtonItem.isEnabled = false
        }
        
        self.reloadEmptyState()
    }
    
    /// Calculates the percentage for the progress ring
    func calculateProgress() {
        guard assignments.count > 0 else {
            self.progressRing.setProgress(value: 0, animationDuration: 0, completion: nil)
            return
        }
        
        var weights = 0.0
        var score = 0.0
        
        for (indexOfRubric, rubric) in rubrics.enumerated() {
            let assignments = self.assignments[indexOfRubric]
            if assignments.count == 0 { continue }
            
            weights += rubric.weight
            
            var total = 0.0
            
            for assignment in assignments {
                total += assignment.score
            }
            
            total /= Double(assignments.count)
            score += rubric.weight * total
        }
        
        self.progressRing.setProgress(value: CGFloat(score / weights), animationDuration: 1.5, completion: nil)
    }
    
    func assignment(for indexPath: IndexPath) -> Assignment {
        return assignments[indexPath.section][indexPath.row]
    }
    
    func deleteAssignment(at indexPath: IndexPath) {
        let assignmentToDelete = assignment(for: indexPath)
        
        try! realm.write {
            realm.delete(assignmentToDelete)
        }
        
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .left)
        self.tableView.reloadSections(IndexSet.init(integer: indexPath.section), with: .fade)
        self.tableView.endUpdates()
        self.reloadEmptyState()

        calculateProgress()
    }
    
    deinit { self.classObj = nil }
}

// MARK: - UIEmptyState DataSource & Delegate

extension ClassDetailTableViewController: UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    // DataSource

    func shouldShowEmptyStateView(forTableView tableView: UITableView) -> Bool {
        // If no assignments for this class then hide the progress ring and show empty state view
        guard let classObj = self.classObj else {
            self.progressRing.isHidden = true
            return !shouldShowBlank
        }
        
        let noAssignments = classObj.assignments.count == 0
        self.progressRing.isHidden = noAssignments
        return noAssignments && !shouldShowBlank
    }
    
    func titleForEmptyStateView() -> NSAttributedString {
        // If no class selected, tell user to select one
        guard let _ = classObj else {
            let attrsForSelect = [NSForegroundColorAttributeName: UIColor.mutedText,
                                  NSFontAttributeName: UIFont.systemFont(ofSize: 20)]
            return NSAttributedString(string: "Select a class", attributes: attrsForSelect)
        }
        // Display the title
        let attrs = [NSForegroundColorAttributeName: UIColor.lightText,
                     NSFontAttributeName: UIFont.systemFont(ofSize: 20)]
        return NSAttributedString(string: "No Assignments Added", attributes: attrs)
    }
    
    func detailMessageForEmptyStateView() -> NSAttributedString? {
        guard let _ = classObj else { return nil }
        
        let attrs = [NSForegroundColorAttributeName: UIColor.mutedText,
                     NSFontAttributeName: UIFont.systemFont(ofSize: 15)]
        return NSAttributedString(string: "Add an assignment to this class to get started.", attributes: attrs)
    }
    
    func buttonTitleForEmptyStateView() -> NSAttributedString? {
        guard let _ = classObj else { return nil }
        
        let attrs = [NSForegroundColorAttributeName: UIColor.tronGreen,
                     NSFontAttributeName: UIFont.systemFont(ofSize: 18)]
        return NSAttributedString(string: "Add assignment", attributes: attrs)
    }
    
    func buttonImageForEmptyStateView() -> UIImage? {
        guard let _ = classObj else { return nil }
        
        return #imageLiteral(resourceName: "buttonBg")
    }
    
    func buttonSizeForEmptyStateView() -> CGSize? {
        guard let _ = classObj else { return nil }
        
        return CGSize(width: 170, height: 50)
    }
    
    // Delegate
    
    func emptyStatebuttonWasTapped(button: UIButton) {
        self.performSegue(withIdentifier: .addEditAssignment, sender: button)
    }

}

// MARK: - Segues

extension ClassDetailTableViewController: Segueable {
    /// Conformace to Segueable
    enum SegueIdentifier: String {
        case addEditAssignment = "addEditAssignment"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(forSegue: segue) {
        case .addEditAssignment:
            // Prepare view for segue
            let vc = (segue.destination as! UINavigationController).topViewController as! AddEditAssignmentTableViewController
            vc.parentClass = self.classObj
            vc.delegate = self
            // If editing (coming from edit action) set the assignmt for edit of the ViewController
            if let assignmentForEdit = sender as? Assignment { vc.assignmentForEdit = assignmentForEdit }
        }
    }
}


// MARK: - AddEditAssignmentViewDelegate

extension ClassDetailTableViewController: AddEditAssignmentViewDelegate {
    func didFinishCreating(assignment: Assignment) {

        guard let section = rubrics.index(of: assignment.associatedRubric!), let row = assignments[section].index(of: assignment) else {
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
        
        self.reloadEmptyState()
        
        // Dont call for calculation here if not in split view because this gets called in viewDidAppear
        // Only needed here if in splitView because then viewDidAppear wont be called when coming back from adding assignment
        guard let svc = splitViewController, !svc.isCollapsed else { return }
        
        self.calculateProgress()
    }
    
    func didFinishUpdating(assignment: Assignment) {
        self.tableView.reloadData()
        self.reloadEmptyState()
    }
}
