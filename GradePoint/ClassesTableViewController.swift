//
//  MasterViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 10/12/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift
import UIEmptyState

class ClassesTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    lazy var semesterSections: [Semester] = {
        // Returns a uniquely sorted array of Semesters, these will be our sections for the tableview
        return self.generateSemestersForSections()
    }()

    /// A 2D array of Realm results grouped by their appropriate section
    var classesBySection = [Results<Class>]()
    
    var editingIndexPath: IndexPath?
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Split view delegation and customization
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible
    
        
        // Set delegate and data source for UIEmptyState
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        
        // Remove seperator lines from empty cells
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = UIColor.tableViewSeperator
        
        // Add 3D touch support to this view
        if traitCollection.forceTouchCapability == .available { registerForPreviewing(with: self, sourceView: self.view) }
        
        // Create the 2D array of Class objects, segmented by their appropriate section in the tableview
        initClassesBySection()
        
        // Inital state for empty state view
        self.reloadEmptyState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return classesBySection.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classesBySection[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return classesBySection[section].count > 0 ? 44 : 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Create the correct headerView for the section
        let semForSection = semesterSections[section]
        
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 44))
        mainView.backgroundColor = UIColor.tableViewHeader
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: mainView.bounds.size.width, height: 44))
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.unselected
        label.backgroundColor = UIColor.tableViewHeader
        mainView.addSubview(label)
        
        // Set the correct label text
        label.text = "\(semForSection.term) \(semForSection.year)"
        
        return mainView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell", for: indexPath) as! ClassTableViewCell
        
        let classItem = classObj(forIndexPath: indexPath)
        // Set the cell labels
        cell.classTitleLabel.text = classItem.name
        cell.classDateLabel.text = "\(classItem.semester!.term) \(classItem.semester!.year)"
        cell.ribbonColor = classItem.color
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: { [unowned self] action, indexPath in
            self.editingIndexPath = indexPath
            self.performSegue(withIdentifier: .addEditClass, sender: action)
        })
        
        editAction.backgroundColor = UIColor.info
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { [unowned self] action, indexPath in
            
            // Present alert to user
            let title = NSAttributedString(string: "Delete This Class", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20)])
            let messageAttrs = [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.warning]
            let message = NSAttributedString(string: "This cannot be undone, are you sure?", attributes: messageAttrs)
            var size = CGSize(width: self.view.bounds.size.width - 50, height: 200)
            size = size.width >= 300 ? CGSize(width: 300, height: 200) : CGSize(width: size.width, height: 200)
            let alert = UIBlurAlertController(size: size, title: title, message: message)
            let cancel = UIButton()
            cancel.setTitle("Cancel", for: .normal)
            cancel.backgroundColor = UIColor.info
            
            let delete = UIButton()
            delete.setTitle("Delete", for: .normal)
            delete.backgroundColor = UIColor.warning
            
            alert.addButton(button: cancel, handler: { [weak self] in
                self?.tableView.isEditing = false
            })
            alert.addButton(button: delete, handler: { [weak self] in
                self?.tableView.isEditing = false
                // Delete the class
                self?.deleteClassObj(at: indexPath)
            })
            alert.presentAlert(presentingViewController: self)
        })
        deleteAction.backgroundColor = UIColor.warning
        
        return [deleteAction, editAction]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: .showDetail, sender: tableView.cellForRow(at: indexPath)!)
    }
    
    // MARK: - Helpers
    
    /// This generates all of the possible Semester combinations, this array will be the sections for the table view, currently 48 sections total
    func generateSemestersForSections() -> [Semester] {
        let terms = Semester.terms
        let years = UISemesterPickerView.createArrayOfYears()
        var results = [Semester]()
        
        for year in years {
            for term in terms {
                results.append(Semester(withTerm: term, andYear: year))
            }
        }
        return results
    }
    
    /// This initializes the classesBySection array which is a 2D array that has Realm result objects grouped by their appropriate section
    func initClassesBySection() {
        for semester in semesterSections {
            let classesForSemester = try! Realm().objects(Class.self).filter("semester.term == %@ AND semester.year == %@", semester.term, semester.year)
            classesBySection.append(classesForSemester)
        }
    }
    
    /// Returns a classObj for the sent in index path, used for tableview methods
    func classObj(forIndexPath indexPath: IndexPath) -> Class {
        return classesBySection[indexPath.section][indexPath.row]
    }
    
    /// Deletes a classObj from Realm using a specified indexPath
    func deleteClassObj(at indexPath: IndexPath) {
        // Grab the objects to delete from DB, sincce realm doesnt delete associated objects
        let classToDel = classObj(forIndexPath: indexPath)
        let rubricsToDel = classToDel.rubrics
        let semesterToDel = classToDel.semester!
        let assignmentsToDel = classToDel.assignments
        let gradeToDel = classToDel.grade!
        
        // Figure out whether we need to update the state of the detail controller or not
        // If yes then remove the detail controllers classObj, which will cause the view to configure and show correct message
        var shouldUpdateDetail = false
        let detailController = (splitViewController?.viewControllers.last as? UINavigationController)?.childViewControllers.first as? ClassDetailTableViewController
        if detailController?.classObj == classToDel { shouldUpdateDetail = true }
        
        // Delete class object and its associated properties from Realm
        let realm = try! Realm()
        try! realm.write {
            realm.delete(rubricsToDel)
            realm.delete(semesterToDel)
            realm.delete(assignmentsToDel)
            realm.delete(gradeToDel)
            realm.delete(classToDel)
        }
        
        // Update detail if needed
        if shouldUpdateDetail {
            detailController?.classObj = nil
            detailController?.updateUI()
        }
        else {
            detailController?.updateUI()
        }
        
        // Refresh tableView 
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        // Check to see if this row is the last one in the section, if so reload that section also so the header goes away
        if classesBySection[indexPath.section].isEmpty {
            self.tableView.reloadSections(IndexSet.init(integer: indexPath.section), with: .automatic)
        }
        self.tableView.endUpdates()
        self.reloadEmptyState()
    }
}

// MARK: UIEmptyState Data Source & Delegate

extension ClassesTableViewController: UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    // Empty State Data Source
    
    func shouldShowEmptyStateView(forTableView tableView: UITableView) -> Bool {
        // If not items then empty, show empty state
        return try! Realm().objects(Class.self).isEmpty
    }
    
    var emptyStateTitle: NSAttributedString {
        let attrs = [NSForegroundColorAttributeName: UIColor.mainText,
                     NSFontAttributeName: UIFont.systemFont(ofSize: 20)]
        return NSAttributedString(string: "No Classes Added", attributes: attrs)
    }
    
    var emptyStateImage: UIImage? { return #imageLiteral(resourceName: "EmptyClassesIcon") }
    
    var emptyStateButtonTitle: NSAttributedString? {
        let attrs = [NSForegroundColorAttributeName: UIColor.accentGreen,
                     NSFontAttributeName: UIFont.systemFont(ofSize: 18)]
        return NSAttributedString(string: "Add a class", attributes: attrs)
    }
    
    var emptyStateButtonImage: UIImage? { return #imageLiteral(resourceName: "ButtonBg") }
    
    var emptyStateButtonSize: CGSize? { return CGSize(width: 160, height: 45) }
    
    // Empty State Delegate
    
    func emptyStatebuttonWasTapped(button: UIButton) {
        self.performSegue(withIdentifier: .addEditClass, sender: button)
    }
}

/// MARK: Segues

extension ClassesTableViewController: Segueable {
    
    /// Conformance for Seguable protocol
    enum SegueIdentifier: String {
        case showDetail = "showDetail"
        case addEditClass = "addEditClass"
        case onboarding = "onboardingSegue"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(forSegue: segue) {
        case .showDetail:
            guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else { return }
            
            let classItem = classObj(forIndexPath: indexPath)
            let controller = (segue.destination as! UINavigationController).topViewController as! ClassDetailTableViewController
            controller.classObj = classItem
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            
        case .addEditClass:
            guard let controller = segue.destination as? AddEditClassViewController else { return }
            // If editing then set the appropriate obj into the view controller
            if let _ = sender as? UITableViewRowAction, let path = editingIndexPath {
                controller.classObj = classObj(forIndexPath: path)
            }
            // Assign the delegate
            controller.delegate = self
            // Collapse any edit actions for the tableview, so theyre not opened when returning
            self.tableView.isEditing = false
            
        case .onboarding:
            break
        }
    }
}

// MARK: 3D Touch Delegation

extension ClassesTableViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath) else { return nil }
        guard let peekVC = storyboard?.instantiateViewController(withIdentifier: "ClassPeekViewController") as? ClassPeekViewController else { return nil }
        
        let classObj = self.classObj(forIndexPath: indexPath)
        peekVC.setProgress(for: classObj)
        peekVC.preferredContentSize = CGSize(width: 240.0, height: 240.0)
        peekVC.indexPathForPeek = indexPath
        previewingContext.sourceRect = cell.frame
        
        return peekVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let indexPath = (viewControllerToCommit as? ClassPeekViewController)?.indexPathForPeek else { return }
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        self.performSegue(withIdentifier: .showDetail, sender: cell)
    }
}

// MARK: AddEditClassView Delegation

extension ClassesTableViewController: AddEditClassViewDelegate {
    func didFinishUpdating(classObj: Class) {
        self.tableView.reloadData()
        self.reloadEmptyState()
        // Also update detail controller if presenting this updated class
        let detailController = (splitViewController?.viewControllers.last as? UINavigationController)?.childViewControllers.first as? ClassDetailTableViewController
        if detailController?.classObj == classObj {
            detailController?.classObj = classObj
            detailController?.updateUI()
        }
    }
    
    func didFinishCreating(newClass classObj: Class) {
        guard let section = self.section(forMatchingSemester: classObj.semester!), let row = classesBySection[section].index(of: classObj) else {
            print("Couldnt get index for newly created class object, simply reloading tableview and exiting...")
            return
        }
        
        let indexPath = IndexPath(row: row, section: section)
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [indexPath], with: .automatic)
        self.tableView.reloadSections(IndexSet.init(integer: indexPath.section), with: .automatic)
        self.tableView.endUpdates()
        self.reloadEmptyState()
        
        // Also update the detail views context message
        let detailNav = splitViewController?.viewControllers.last as? UINavigationController
        let detailController = detailNav?.childViewControllers.first as? ClassDetailTableViewController
        detailController?.updateUI()
    }
    
    
    private func section(forMatchingSemester semester: Semester) -> Int? {
        var indexOfMatch: Int?
        for (index, secSemester) in semesterSections.enumerated() {
            if semester.year == secSemester.year && semester.term == secSemester.term {
                indexOfMatch = index
                break
            }
        }
        return indexOfMatch
    }
}

// MARK: - Split vie

extension ClassesTableViewController: UISplitViewControllerDelegate {

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController,
                             onto primaryViewController:UIViewController) -> Bool {
        guard let detailNavController = secondaryViewController as? UINavigationController else { return false }
        guard let detailController = detailNavController.topViewController as? ClassDetailTableViewController else { return false }
        if detailController.classObj == nil { return true }
        return false
    }
}
