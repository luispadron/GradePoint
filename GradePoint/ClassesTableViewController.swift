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
import LPSnackbar

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

    /**
     The datasource for the tableview.
     
     This is a two dimensional array which contains array of Class objects.
     The first array in the array is for any classes which are also favorites.
     The rest are arrays of classes grouped by their semester.
     */
    var classes: [[Class]] = [[Class]]()

    
    /// The search controller used to filter the table view
    let searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    /// Helper property to determine whether search bar is active
    var isSearchActive: Bool {
        get {
            return searchController.isActive && searchController.searchBar.text != ""
        }
    }
    
    /// The section number for the favorites section
    private let favoritesSection: Int = 0
    
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
    
        // Initially reload the classes array since empty at first launch
        self.reloadClasses()
        
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
                self.reloadClasses()
                self.tableView.reloadData()
                self.reloadEmptyState()
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return classes.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard !isSearchActive else { return 0 }
        return classes[section].count > 0 ? 44 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    /// Creates a custom header view for a section
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 44))
        mainView.backgroundColor = UIColor.tableViewHeader
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: mainView.bounds.size.width, height: 44))
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.unselected
        label.backgroundColor = UIColor.tableViewHeader
        mainView.addSubview(label)
        
        // Set correct label text
        if section == favoritesSection {
            label.text = "Favorites"
        } else {
            let semForSection = semesterSections[section - 1] // - 1 due to the favorites section
            label.text = "\(semForSection.term) \(semForSection.year)"
        }
        
        return mainView
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Don't allow editing if search is active
        return !isSearchActive
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell", for: indexPath) as! ClassTableViewCell
        
        let classItem: Class = classObj(at: indexPath)
        
        // Set the cell labels
        cell.classTitleLabel.text = classItem.name
        cell.classDateLabel.text = "\(classItem.semester!.term) \(classItem.semester!.year)"
        cell.ribbonColor = classItem.color
        
        return cell
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favorite = UIContextualAction(style: .normal, title: "Favorite", handler: { action, view, finished in
            finished(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.updateFavoriteState(at: indexPath)
            }
        })
        
        let classAtPath = classObj(at: indexPath)
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
            self.handleDelete(at: indexPath)
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
        let classObjAtPath = classObj(at: indexPath)
        
        if classObjAtPath.isClassInProgress {
            self.performSegue(withIdentifier: .showDetail, sender: indexPath)
        } else {
            self.performSegue(withIdentifier: .showPreviousDetail, sender: indexPath)
        }
    }
    
    // MARK: - Helpers
    
    /// This generates all of the possible Semester combinations, this array will be the sections for the table view
    private func generateSemestersForSections() -> [Semester] {
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
    
    /// Reloads and updates the `classes` array
    private func reloadClasses() {
        let realm = try! Realm()
        self.classes.removeAll()
        // Set first array in the 2D array as an array of favorited classes
        let all = realm.objects(Class.self)
        self.classes.append(all.filter { $0.isFavorite }.sorted { $0.semester!.year > $1.semester!.year})
        // The rest of the arrays inside the `classes` array will be grouped by their semester
        semesterSections.forEach {
            let classes = Array(all.filter("semester.term == %@ AND semester.year == %@", $0.term, $0.year))
            self.classes.append(classes)
        }
    }
    
    private func filterClasses(for search: String) {
        let realm = try! Realm()
        self.classes.removeAll()
        let all = realm.objects(Class.self)
        self.classes.append(all.filter { $0.name.contains(search) })
    }
    
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
    
    /// Returns a classObj for the sent in index path, used for tableview methods
    private func classObj(at indexPath: IndexPath) -> Class {
        return classes[indexPath.section][indexPath.row]
    }
    
    /// Handles the deleting of a table view row and class object
    private func handleDelete(at deletePath: IndexPath) {
        let classToDel = classObj(at: deletePath)

        guard classToDel.isFavorite == true else {
            // Class isnt a favorite, we can just go ahead and remove the single cell
            removeCells(at: [deletePath], classObj: classToDel)
            return
        }

        // Since favorited classes appear twice in the table view, we need to make sure we're removing both cells
        if deletePath.section == favoritesSection {
            // Find path of class in `classes` not including the section which contains the favorites, which is the 0th element
            var classesFavoritesRemoved = classes
            classesFavoritesRemoved.remove(at: favoritesSection)
            if let indices = classesFavoritesRemoved.indices(of: classToDel) {
                removeCells(at: [deletePath, IndexPath(row: indices.1, section: indices.0 + 1)], classObj: classToDel)
            } else {
                LPSnackbar.showSnack(title: "Error deleting class.")
            }
        } else {
            // Find path of class in favorites part of the classes array
            if let index = classes[favoritesSection].index(of: classToDel) {
                removeCells(at: [deletePath, IndexPath(row: index, section: favoritesSection)], classObj: classToDel)
            } else {
                LPSnackbar.showSnack(title: "Error deleting class.")
            }
        }
    }
    
    /// Removes the cells from the table view and presents an LPSnackbar in order to allow undo
    private func removeCells(at indexPaths: [IndexPath], classObj: Class) {
        // Block which reloads any sections if it's needed
        let reloadSectionsIfNeed: () -> Void = { [weak self] in
            indexPaths.forEach {
                if self?.classes[$0.section].count ?? -1 == 0 || (self?.classes[$0.section].count ?? 2) - 1 == 0 {
                    self?.tableView.reloadSections(IndexSet.init(integer: $0.section), with: .automatic)
                }
            }
        }
        // Begin updates for the tableview
        self.tableView.beginUpdates()
        // Remove class object from classes array
        indexPaths.forEach { self.classes[$0.section].remove(at: $0.row) }
        self.tableView.deleteRows(at: indexPaths, with: .automatic)
        // Reload sections, if needed
        reloadSectionsIfNeed()
        self.tableView.endUpdates()
        self.reloadEmptyState()
        
        // Figure out whether we need to update the state of the detail controller or not
        // If yes then remove the detail controllers classObj, which will cause the view to configure and show correct message
        var shouldUpdateDetail = false
        var detailController: ClassDetailTableViewController?

        if classObj.isClassInProgress {
            // In progress class
            let navController = (self.splitViewController?.viewControllers.last as? UINavigationController)
            detailController = navController?.childViewControllers.first as? ClassDetailTableViewController
            shouldUpdateDetail = detailController?.classObj == classObj
        } else {
            // Previous class, different process, just hide all the views and move on
            let navController = (self.splitViewController?.viewControllers.last as? UINavigationController)
            let prevDetailController = navController?.childViewControllers.first as? PreviousClassDetailViewController
            prevDetailController?.hideViews()
        }

        // Update detail if needed
        if shouldUpdateDetail {
            detailController?.classObj = nil
            detailController?.updateUIForClassChanges()
        } else {
            detailController?.updateUIForClassChanges()
        }
        
        // Present snackbar to allow user to undo the deletion
        let snack = LPSnackbar(title: "Class deleted.", buttonTitle: "UNDO", displayDuration: nil)
        snack.bottomSpacing = (tabBarController?.tabBar.frame.height ?? 12) + 15
        snack.show() { [weak self] undone in
            if undone {
                self?.tableView.beginUpdates()
                // Re-add the class object into the array, and re-add the cells
                indexPaths.forEach {
                    guard let count = self?.classes[$0.section].count else { return }
                    if $0.row > count {
                        self?.classes[$0.section].append(classObj)
                        self?.tableView.insertRows(at: [IndexPath(row: count - 1, section: $0.section)], with: .automatic)
                    } else {
                        self?.classes[$0.section].insert(classObj, at: $0.row)
                        self?.tableView.insertRows(at: [$0], with: .automatic)
                    }
                }
    
                reloadSectionsIfNeed()
                self?.tableView.endUpdates()
                self?.reloadEmptyState()
            } else {
                // Delete from Realm
                self?.delete(classObj: classObj)
            }
        }
    }
    
    /// Deletes a class from Realm
    private func delete(classObj: Class) {
        // Remove object from Realm
        let realm = try! Realm()
        try! realm.write {
            realm.delete(classObj.rubrics)
            realm.delete(classObj.semester!)
            realm.delete(classObj.assignments)
            realm.delete(classObj.grade!)
            realm.delete(classObj)
        }
    }
    
  
    /// Creates the older legacy swipe actiions for a tableview used in iOS versions less than 11.0
    private func createLegacySwipeActions() -> [UITableViewRowAction] {
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: { [unowned self] _, path in
            self.performSegue(withIdentifier: .addEditClass, sender: path)
        })
        
        editAction.backgroundColor = UIColor.info
        
        let favoriteAction = UITableViewRowAction(style: .normal, title: "Favorite", handler: { [unowned self] _, path in
            self.updateFavoriteState(at: path)
            self.tableView.setEditing(false, animated: true)
        })
        
        favoriteAction.backgroundColor = UIColor.customYellow
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { [unowned self] _, path in
            self.handleDelete(at: path)
        })
        
        deleteAction.backgroundColor = UIColor.warning
        
        
        return [deleteAction, editAction, favoriteAction]
    }
    
    /// Updates a classes favorite state at the specified index path
    private func updateFavoriteState(at indexPath: IndexPath) {
        let realm = try! Realm()
        let classAtPath = self.classObj(at: indexPath)
        
        // Reload tableview and write changes to Realm
        if classAtPath.isFavorite {
            // Remove from favorites section
            self.tableView.beginUpdates()
            // Get the index of the class in the favorites part of the classes array
            let index = classes[0].index(of: classAtPath)!
            // Update property in realm, which will also remove it from the classes first array
            try! realm.write {
                classAtPath.isFavorite = false
            }
            // Reload datasource
            self.reloadClasses()
            // Delete rows
            self.tableView.deleteRows(at: [IndexPath(row: index, section: favoritesSection)], with: .automatic)
            self.tableView.endUpdates()
        } else { // Add to favorites section
            // Update property in realm which will add class to classes array at the 0th index
            try! realm.write {
                classAtPath.isFavorite = true
            }
            // Reload datasource
            self.reloadClasses()
    
            self.tableView.beginUpdates()
            // Get the index of the class in the favorites part of the classes array
            let index = classes[0].index(of: classAtPath)!
            
            // Update tableview
            if classes[0].count - 1 == 0 {
                // This section was previously empty, thus has no header, reload entire seciton
                self.tableView.reloadSections(IndexSet.init(integer: favoritesSection), with: .automatic)
                self.tableView.insertRows(at: [IndexPath(row: index, section: favoritesSection)], with: .automatic)
            } else {
                self.tableView.insertRows(at: [IndexPath(row: index, section: favoritesSection)], with: .automatic)
            }
            self.tableView.endUpdates()
        }
    }
}

// MARK: Conformance for UISearchController

extension ClassesTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText != "" else {
            self.searchController.isActive = false
            self.reloadClasses()
            self.tableView.reloadData()
            self.reloadEmptyState()
            return
        }
        
        // Update classes array to filter for name
        self.filterClasses(for: searchText)
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.isActive = false
        self.reloadClasses()
        self.tableView.reloadData()
        self.reloadEmptyState()
    }
}

// MARK: UIEmptyState Data Source & Delegate

extension ClassesTableViewController: UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    // Empty State Data Source
    
    func shouldShowEmptyStateView(forTableView tableView: UITableView) -> Bool {
        // If not items then empty, show empty state
        return classes.isTrueEmpty
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
    
    func emptyStateViewWillShow(view: UIView) {
        // Deactivate the search controller
        if #available(iOS 11.0, *) {
            self.searchController.isActive = false
        } else {
            self.searchController.isActive = false
            self.tableView.tableHeaderView = nil
        }
    }
    
    func emptyStateViewWillHide(view: UIView) {
        // Re add the searchbar, only needs to be done for iOS 10.0 or lower
        if #available(iOS 11.0, *) {
            return
        } else {
            if self.tableView.tableHeaderView == nil {
                self.tableView.tableHeaderView = self.searchController.searchBar
            }
        }
    }
    
    func emptyStatebuttonWasTapped(button: UIButton) {
        self.performSegue(withIdentifier: .addEditClass, sender: button)
    }
}

// MARK: Segues

extension ClassesTableViewController: Segueable {
    
    /// Conformance for Seguable protocol
    enum SegueIdentifier: String {
        case showDetail = "showDetail"
        case showPreviousDetail = "showPreviousDetail"
        case addEditClass = "addEditClass"
        case onboarding = "onboardingSegue"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Do any preperations before performing segue
        switch segueIdentifier(forSegue: segue) {
            
        case .showDetail:
            guard let indexPath = sender as? IndexPath else {
                return
            }
            
            let classItem: Class = classObj(at: indexPath)
            
            let controller = (segue.destination as! UINavigationController).topViewController as! ClassDetailTableViewController
            controller.classObj = classItem
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            
        case .showPreviousDetail:
            guard let indexPath = sender as? IndexPath else {
                return
            }
            
            let classItem: Class = classObj(at: indexPath)
            
            let controller = (segue.destination as! UINavigationController).topViewController as! PreviousClassDetailViewController
            controller.title = "Previous Class"
            controller.className = classItem.name
            controller.gradeString = classItem.grade?.gradeLetter
            controller.classColor = classItem.color
            
        case .addEditClass:
            guard let controller = segue.destination as? AddEditClassViewController else { return }
            
            // If editing then set the appropriate obj into the view controller, when user clicks edit
            // the sender provided will be an index path, using this we can get the object at that path
            if let path = sender as? IndexPath {
                controller.classObj = classObj(at: path)
            }
            
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
        
        // Revert and undo any searches
        searchController.isActive = false
        self.reloadClasses()
        self.tableView.reloadData()
        self.reloadEmptyState()
        
    }
}

// MARK: 3D Touch Delegation

extension ClassesTableViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath) else { return nil }
        guard let peekVC = storyboard?.instantiateViewController(withIdentifier: "ClassPeekViewController") as? ClassPeekViewController else { return nil }
        
        // Only allow peeking for in progress classes
        let classObj = self.classObj(at: indexPath)
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
            detailController?.updateUIForClassChanges()
        }
    }
    
    func didFinishCreating(newClass classObj: Class) {
        // Reload classes since new object has been added
        self.reloadClasses()
        
        guard var section = self.sectionforMatchingSemester(classObj.semester!) else {
            print("ERROR: Unable to find a section for matching semester.")
            return
        }
        
        // Since favorites is always at the 0th in the classes array
        section += 1
        
        guard let row = classes[section].index(of: classObj) else {
            print("ERROR: Couldnt get index for newly created class object")
                return
        }
        
        let indexPath: IndexPath = IndexPath(row: row, section: section)
        
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [indexPath], with: .automatic)
        self.tableView.reloadSections(IndexSet.init(integer: indexPath.section), with: .automatic)
        self.tableView.endUpdates()
        self.reloadEmptyState()
    }
    
    
    private func sectionforMatchingSemester(_ semester: Semester) -> Int? {
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
        guard let detailNavController = secondaryViewController as? UINavigationController else { return true }
        if let detailController = detailNavController.topViewController as? ClassDetailTableViewController {
            // In progress class, only collapse if classObj is nil
            return detailController.classObj == nil
        } else if let prevDetailController = detailNavController.topViewController as? PreviousClassDetailViewController {
            // Previous class, only collapse if views are hidden, if `bgView` is hidden, safe to assume they all are
            return prevDetailController.bgView.isHidden
        }
        
        
        return false
    }
}
