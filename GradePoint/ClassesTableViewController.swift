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

class ClassesTableViewController: UITableViewController, UIEmptyStateDataSource, UIEmptyStateDelegate, Segueable {
    
    // MARK: - Properties
    
    var realm = try! Realm()
    var notificationToken: NotificationToken?
    
    var detailViewController: ClassDetailTableViewController? = nil
    
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
        // Set delegate and data source for UIEmptyState
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        
        // Set bar button item
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        // Remove seperator lines from empty cells
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // Create realm notification block
        notificationToken = realm.addNotificationBlock { [unowned self] note, realm in
            self.tableView.reloadData()
            self.reloadEmptyState(forTableView: self.tableView)
        }
        
        // Create the 2D array of Class objects, segmented by their appropriate section in the tableview
        initClassesBySection()
        
        // Inital state for empty state view
        self.reloadEmptyState(forTableView: self.tableView)
        
        
        if let split = self.splitViewController {
            split.preferredDisplayMode = .allVisible
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ClassDetailTableViewController
            
            // TODO: Add support for saving of last selected item and loading that initially
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        self.tableView.separatorColor = UIColor.tableViewSeperator
        super.viewWillAppear(animated)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: mainView.bounds.size.width, height: 44))
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
        
        // Set the cells associated class, all UI updates are done in the ClassTableViewCell class
        cell.classObj = classItem
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: { [unowned self] action, indexPath in
            self.editingIndexPath = indexPath
            self.performSegue(withIdentifier: .addEditClass, sender: action)
        })
        
        editAction.backgroundColor = UIColor.lapisLazuli
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { [unowned self] action, indexPath in
            self.deleteClassObj(at: indexPath)
        })
        deleteAction.backgroundColor = UIColor.sunsetOrange
        
        return [deleteAction, editAction]
    }
    
    // MARK: - UIEmptyState Data Source
    
    func shouldShowEmptyStateView(forTableView tableView: UITableView) -> Bool {
        // If not items then empty, show empty state
        return realm.objects(Class.self).isEmpty
    }
    
    func titleForEmptyStateView() -> NSAttributedString {
        let attrs = [NSForegroundColorAttributeName: UIColor.lightText,
                     NSFontAttributeName: UIFont.systemFont(ofSize: 20)]
        return NSAttributedString(string: "No Classes Added", attributes: attrs)
    }
    
    func detailMessageForEmptyStateView() -> NSAttributedString? {
        return nil
    }
    
    func imageForEmptyStateView() -> UIImage? {
        return #imageLiteral(resourceName: "EmptyClassesIcon")
    }
    
    func buttonImageForEmptyStateView() -> UIImage? {
        return #imageLiteral(resourceName: "buttonBg")
    }
    
    func buttonSizeForEmptyStateView() -> CGSize? {
        return CGSize(width: 160, height: 45)
    }
    
    // MARK: UIEmptyState Delegate
    
    func emptyStatebuttonWasTapped(button: UIButton) {
        self.performSegue(withIdentifier: .addEditClass, sender: button)
    }
    
    func buttonTitleForEmptyStateView() -> NSAttributedString? {
        let attrs = [NSForegroundColorAttributeName: UIColor.tronGreen,
                     NSFontAttributeName: UIFont.systemFont(ofSize: 18)]
        return NSAttributedString(string: "Add a class", attributes: attrs)
    }
    
    // MARK: - Segues
    
    /// Conformance for Seguable protocol
    enum SegueIdentifier: String {
        case showDetail = "showDetail"
        case addEditClass = "addEditClass"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifier(forSegue: segue) {
        case .showDetail:
            guard let indexPath = self.tableView.indexPathForSelectedRow else {
                fatalError("Index path for selected row was nil")
            }
            let classItem = classObj(forIndexPath: indexPath)
            let controller = (segue.destination as! UINavigationController).topViewController as! ClassDetailTableViewController
            controller.detailItem = classItem
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        
        case .addEditClass:
            let nav = segue.destination as! UINavigationController
            let controller = nav.topViewController as! AddEditClassTableViewController
            // If editing then set the appropriate obj into the view controller
            if let _ = sender as? UITableViewRowAction, let path = editingIndexPath {
                controller.classObj = classObj(forIndexPath: path)
            }
            nav.preferredContentSize = CGSize(width: 500, height: 600)
        }
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
            let classesForSemester = realm.objects(Class.self).filter("semester.term == %@ AND semester.year == %@", semester.term, semester.year)
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
        
        try! realm.write {
            realm.delete(rubricsToDel)
            realm.delete(semesterToDel)
            realm.delete(assignmentsToDel)
            realm.delete(classToDel)
        }
    }
    
    // MARK: - Deinit
    
    // Stop notifications
    deinit {
        notificationToken?.stop()
    }
}

