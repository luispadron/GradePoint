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
    
    /// The last valid loaded terms from user defaults
    var lastLoadedTerms: [String]?
    
    /// Returns a uniquely sorted array of Semesters, these will be our sections for the tableview
    var semesterSections: [Semester] {
        get {
            return self.generateSemestersForSections()
        }
    }

    /// The search controller used to filter the table view
    let searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    /// A 2D array of Realm results grouped by their appropriate section
    var classesBySection = [Results<Class>]()
    
    /// A filtered array of classes, filtered using text entered in the search contoller
    var filteredClasses = [Class]()
    
    /// The index path of the class the user wants to edit
    var editingIndexPath: IndexPath?
    
    /// Helper property to determine whether search bar is active
    var isSearchActive: Bool {
        get {
            return searchController.isActive  && searchController.searchBar.text != ""
        }
    }
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up large titles if on iOS 11
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // Split view delegation and customization
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible
    
        
        // Add scrolls to top gesture
        self.tableView.scrollsToTop = true
        
        // Set delegate and data source for UIEmptyState
        self.emptyStateDataSource = self
        self.emptyStateDelegate = self
        
        // Set delegates and view settings for SearchController
        setupSearchbar()
        
        // Remove seperator lines from empty cells, and remove white background around navbars
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = UIColor.tableViewSeperator
        self.tableView.backgroundView = UIView()
        
        // Add 3D touch support to this view
        if traitCollection.forceTouchCapability == .available { registerForPreviewing(with: self, sourceView: self.view) }
        
        // Create the 2D array of Class objects, segmented by their appropriate section in the tableview
        initClassesBySection()
        
        // Setup tableview estimates
        self.tableView.estimatedRowHeight = 60
        self.tableView.estimatedSectionHeaderHeight = 44
        self.tableView.estimatedSectionFooterHeight = 0
        
        // Inital state for empty state view
        self.reloadEmptyState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        
        // Check to see if saved terms have changed
        let key = UserDefaultKeys.terms.rawValue
        if let t = UserDefaults.standard.stringArray(forKey: key), let terms = self.lastLoadedTerms {
            if terms != t {
                self.classesBySection.removeAll()
                self.initClassesBySection()
                self.tableView.reloadData()
                self.reloadEmptyState()
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isSearchActive {
            return 1
        } else {
            return classesBySection.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive {
            return filteredClasses.count
        } else {
            return classesBySection[section].count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearchActive { return 0 }
        else { return classesBySection[section].count > 0 ? 44 : 0 }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !isSearchActive else { return nil }
        
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
        
        let classItem: Class
        
        if isSearchActive {
            classItem = filteredClasses[indexPath.row]
        } else {
            classItem = classObj(forIndexPath: indexPath)
        }
        
        // Set the cell labels
        cell.classTitleLabel.text = classItem.name
        cell.classDateLabel.text = "\(classItem.semester!.term) \(classItem.semester!.year)"
        cell.ribbonColor = classItem.color
        
        return cell
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let classAtPath = classObj(forIndexPath: indexPath)

        let favorite = UIContextualAction(style: .normal, title: "Favorite", handler: { action, view, finished in
            let realm = try! Realm()
            try! realm.write {
                classAtPath.isFavorite = !classAtPath.isFavorite
            }
            
            finished(true)
        })
        
        favorite.backgroundColor = UIColor.favorite
        
        let image: UIImage = classAtPath.isFavorite ? #imageLiteral(resourceName: "FavoriteIconFilled") : #imageLiteral(resourceName: "FavoriteIcon")
        
        favorite.image = image
        
        let configuration = UISwipeActionsConfiguration(actions: [favorite])
        return configuration
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit", handler: { _, _, finished in
            self.performSegue(withIdentifier: .addEditClass, sender: indexPath)
            finished(true)
        })
        
        edit.backgroundColor = UIColor.info
        edit.image = #imageLiteral(resourceName: "EditIcon")
        
        let delete = UIContextualAction(style: .normal, title: "Delete", handler: { _, _, finished in
            self.presentDeleteAlert(at: indexPath)
            finished(true)
        })
        
        delete.backgroundColor = UIColor.warning
        delete.image = #imageLiteral(resourceName: "EraseIcon")
        
        let configuration = UISwipeActionsConfiguration(actions: [edit, delete])
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard #available(iOS 11.0, *) else {
            // Use older swipe actions for any iOS less than 11.0
            return createLegacySwipeActions()
        }
        
        // Use new swipe actions API in iOS 11.0 +
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: .showDetail, sender: tableView.cellForRow(at: indexPath)!)
    }
    
    // MARK: - Helpers
    
    /// Sets up the search bar for the tableview
    private func setupSearchbar() {
        if #available(iOS 11.0, *)  {
            // Search bar handeling different for iOS 11, is added as part of the navigation controller instead
            searchController.searchBar.delegate = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Search"
            self.navigationItem.searchController = searchController

        } else {
            searchController.searchBar.delegate = self
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Search classes"
            searchController.searchBar.barTintColor = UIColor(red: 0.337, green: 0.337, blue: 0.376, alpha: 1.00)
            
            self.tableView.contentOffset = CGPoint(x: 0, y: self.tableView.contentOffset.y +
                                                            searchController.searchBar.frame.height)
            
            tableView.tableHeaderView = searchController.searchBar
        }
    }
    
    
    /// This generates all of the possible Semester combinations,
    /// this array will be the sections for the table view, currently 48 sections total
    func generateSemestersForSections() -> [Semester] {
        let terms: [String]
        
        /// Load semesters from user defaults, if for some reason this isnt saved, fall back to default semesters
        if let t = UserDefaults.standard.stringArray(forKey: UserDefaultKeys.terms.rawValue) {
            terms = t
        } else {
            print("WARNING: Something went wrong when loading semesters from UserDefaults, loading default set instead.")
            terms = ["Spring", "Summer", "Fall", "Winter"]
        }
        
        lastLoadedTerms = terms
    
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
    
    /// Updates the tableview to the filtered classes array user searched for
    func filterClasses(forSearchText searchText: String, scope: String = "All") {
        // First flatten the 2D array
        let flatClasses = Array(classesBySection.joined())
        
        filteredClasses = flatClasses.filter { classObj in
            return classObj.name.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    private func presentDeleteAlert(at indexPath: IndexPath) {
        // Present alert to user
        let title = NSAttributedString(string: "Delete This Class",
                                       attributes: [.font: UIFont.systemFont(ofSize: 20)])
        
        let messageAttrs: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: 16),
                                                          .foregroundColor: UIColor.warning]
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
    
        if self.searchController.isActive {
            alert.presentAlert(presentingViewController: self.searchController)
        } else {
            alert.presentAlert(presentingViewController: self)
        }
    }
    
    /// Deletes a classObj from Realm using a specified indexPath
    private func deleteClassObj(at indexPath: IndexPath) {
        // Grab the objects to delete from DB, sincce realm doesnt delete associated objects
        let classToDel: Class
        
        if isSearchActive {
            classToDel = filteredClasses[indexPath.row]
        } else {
            classToDel = classObj(forIndexPath: indexPath)
        }
        
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
        // If were in the search controller also remove this class from the filtered classes array
        // Since this array is just a flat copy of classesBySection, but hasn't been updated when deleting
        if isSearchActive {
            filteredClasses.remove(at: indexPath.row)
        }
        // Check to see if this row is the last one in the section, if so reload that section also so the header goes away
        if classesBySection[indexPath.section].isEmpty {
            self.tableView.reloadSections(IndexSet.init(integer: indexPath.section), with: .automatic)
        }
        self.tableView.endUpdates()
        self.reloadEmptyState()
    }
    
    /// Creates the older legacy swipe actiions for a tableview used in iOS versions less than 11.0
    private func createLegacySwipeActions() -> [UITableViewRowAction] {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: { [unowned self] _, path in
            self.performSegue(withIdentifier: .addEditClass, sender: path)
        })
        
        editAction.backgroundColor = UIColor.info
        
        let favoriteAction = UITableViewRowAction(style: .normal, title: "Favorite", handler: { [unowned self] _, path in
            let classAtPath = self.classObj(forIndexPath: path)
            let realm = try! Realm()
            try! realm.write {
                classAtPath.isFavorite = !classAtPath.isFavorite
            }
            self.tableView.setEditing(false, animated: true)
        })
        
        favoriteAction.backgroundColor = UIColor.favorite
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { [unowned self] _, path in
            self.presentDeleteAlert(at: path)
        })
        
        deleteAction.backgroundColor = UIColor.warning
        
        
        return [deleteAction, editAction, favoriteAction]
    }
}

// MARK: Conformance for UISearchController

extension ClassesTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText != "" else {
            self.searchController.isActive = false
            self.tableView.reloadData()
            self.reloadEmptyState()
            return
        }
        
        filterClasses(forSearchText: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.isActive = false
        self.tableView.reloadData()
        self.reloadEmptyState()
    }
}

// MARK: UIEmptyState Data Source & Delegate

extension ClassesTableViewController: UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    // Empty State Data Source
    
    func shouldShowEmptyStateView(forTableView tableView: UITableView) -> Bool {
        // If not items then empty, show empty state
        let isEmpty = try! Realm().objects(Class.self).isEmpty
        
        if #available(iOS 11.0, *) {
            if isEmpty { searchController.isActive = false }
            return isEmpty
        } else {
            // Make sure to remove search bar on any iOS less than 11.0 from the header view
            // Not needed for >= 11.0 since this is all handled
            if isEmpty {
                // Remove the searchbar
                self.searchController.isActive = false
                self.tableView.tableHeaderView = nil
            } else {
                // Readd search
                if self.tableView.tableHeaderView == nil {
                    self.tableView.tableHeaderView = searchController.searchBar
                }
            }
            
            return isEmpty
        }
    }
    
    var emptyStateTitle: NSAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.mainText,
                                                   .font: UIFont.systemFont(ofSize: 20)]
        return NSAttributedString(string: "No Classes Added", attributes: attrs)
    }
    
    var emptyStateImage: UIImage? { return #imageLiteral(resourceName: "EmptyClassesIcon") }
    
    var emptyStateButtonTitle: NSAttributedString? {
        let attrs: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.accentGreen,
                                                   .font: UIFont.systemFont(ofSize: 18)]
        return NSAttributedString(string: "Add a class", attributes: attrs)
    }
    
    var emptyStateButtonImage: UIImage? { return #imageLiteral(resourceName: "ButtonBg") }
    
    var emptyStateButtonSize: CGSize? { return CGSize(width: 160, height: 45) }
    
    var emptyStateViewAnimatesEverytime: Bool { return false }
    
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
            
            let classItem: Class
            
            if isSearchActive {
                classItem = filteredClasses[indexPath.row]
            } else {
                classItem = classObj(forIndexPath: indexPath)
            }
            
            // Revert and undo any searches
            searchController.isActive = false
            self.tableView.reloadData()
            self.reloadEmptyState()
            
            let controller = (segue.destination as! UINavigationController).topViewController as! ClassDetailTableViewController
            controller.classObj = classItem
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            
        case .addEditClass:
            guard let controller = segue.destination as? AddEditClassViewController else { return }
            
            // If editing then set the appropriate obj into the view controller, when user clicks edit
            // the sender provided will be an index path, using this we can get the object at that path
            if let path = sender as? IndexPath {
                if isSearchActive {
                    controller.classObj = filteredClasses[path.row]
                } else {
                    controller.classObj = classObj(forIndexPath: path)
                }
            }
            
            // Revert and undo any searches
            searchController.isActive = false
            self.tableView.reloadData()
            self.reloadEmptyState()
            
            // Assign the delegate
            controller.delegate = self
            let screenSize = UIScreen.main.bounds.size
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                controller.preferredContentSize = CGSize(width: screenSize.width / 2, height: screenSize.height / 2)
            } else {
                controller.preferredContentSize = CGSize(width: screenSize.width * 0.65, height: screenSize.height * 0.85)
            }
        
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
        
        // Only allow peeking for in progress classes
        let classObj = self.classObj(forIndexPath: indexPath)
        guard classObj.isClassInProgress else { return nil }
        
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

// MARK: - Split view

extension ClassesTableViewController: UISplitViewControllerDelegate {

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController,
                             onto primaryViewController:UIViewController) -> Bool {
        guard let detailNavController = secondaryViewController as? UINavigationController else { return false }
        guard let detailController = detailNavController.topViewController as? ClassDetailTableViewController else { return false }
        if detailController.classObj == nil { return true }
        return false
    }
}
