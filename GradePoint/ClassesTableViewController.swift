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
    
    /// An array of classes that have been favorited by the user, ordered by date
    var favoritedClasses: [Class] {
        get {
            let realm = try! Realm()
            return realm.objects(Class.self).filter { $0.isFavorite }.sorted { $0.semester!.year > $1.semester!.year }
        }
    }
    
    /// The index path of the class the user wants to edit
    var editingIndexPath: IndexPath?
    
    /// Helper property to determine whether search bar is active
    var isSearchActive: Bool {
        get {
            return searchController.isActive && searchController.searchBar.text != ""
        }
    }
    
    /// The section number for the favorites section
    private let favoritesSection: Int = 0
    
    /// The number of extra sections in the tableview, not counting classesBySection
    /// This number needs to be subtracted from sections when accessing classesBySections
    private let accessorySections: Int = 1
    
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
            // Determine number of sections, add any accessory sections for favorites 
            return classesBySection.count + accessorySections
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive {
            return filteredClasses.count
        } else {
            if section == favoritesSection {
                // The favorites section will only contain favorited classes duh...
                return favoritedClasses.count
            } else {
                return classesBySection[section - accessorySections].count
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearchActive {
            return 0
        } else {
            if section == favoritesSection {
                return favoritedClasses.count > 0 ? 44 : 0
            } else  {
                return classesBySection[section - accessorySections].count > 0 ? 44 : 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    /// Creates a custom header view for a section
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !isSearchActive else { return nil }
        
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
            let semForSection = semesterSections[section - accessorySections]
            label.text = "\(semForSection.term) \(semForSection.year)"
        }
        
        return mainView
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
        let classObjAtPath = classObj(at: indexPath)
        
        if classObjAtPath.isClassInProgress {
            self.performSegue(withIdentifier: .showDetail, sender: indexPath)
        } else {
            self.performSegue(withIdentifier: .showPreviousDetail, sender: indexPath)
        }
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
    private func classObj(at indexPath: IndexPath) -> Class {
        if isSearchActive {
            return filteredClasses[indexPath.row]
        } else if indexPath.section == favoritesSection {
            return favoritedClasses[indexPath.row]
        } else {
            return classesBySection[indexPath.section - accessorySections][indexPath.row]
        } 
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
        let realm = try! Realm()
        let classToDel: Class = classObj(at: indexPath)
        
        // Block which deletes all associated objects and the class from realm db
        let deleteAll = {
            try! realm.write {
                realm.delete(classToDel.rubrics)
                realm.delete(classToDel.semester!)
                realm.delete(classToDel.assignments)
                realm.delete(classToDel.grade!)
                realm.delete(classToDel)
            }
        }
        
        // Block for reloading class sections if required
        let reloadClassSectionIfNeeded: (IndexPath) -> Void = { path in
            if self.classesBySection[path.section].count == 0 {
                self.tableView.reloadSections(IndexSet.init(integer: path.section), with: .automatic)
            }
        }
        // Block for reloading the favorites section if required
        let reloadFavoritesSectionIfNeeded: (IndexPath) -> Void = { path in
            if self.favoritedClasses.count == 0 {
                self.tableView.reloadSections(IndexSet.init(integer: path.section), with: .automatic)
            }
        }
        
        // Figure out whether we need to update the state of the detail controller or not
        // If yes then remove the detail controllers classObj, which will cause the view to configure and show correct message
        var shouldUpdateDetail = false
        var detailController: ClassDetailTableViewController?
        
        if classToDel.isClassInProgress {
            // In progress class
            let navController = (splitViewController?.viewControllers.last as? UINavigationController)
            detailController = navController?.childViewControllers.first as? ClassDetailTableViewController
            shouldUpdateDetail = detailController?.classObj == classToDel
        } else {
            // Previous class, different process, just hide all the views and move on
            let navController = (splitViewController?.viewControllers.last as? UINavigationController)
            let prevDetailController = navController?.childViewControllers.first as? PreviousClassDetailViewController
            prevDetailController?.hideViews()
        }
        
        // Remove the cell from the tableView, if the class was a also a favorite, remove the cell from that section too
        if classToDel.isFavorite && !isSearchActive {
            if indexPath.section == favoritesSection {
                // The user selected delete from the favorites section, delete from realm and reload both rows
                // First find the index path under the favorites section for the class were deleting
                var row: Int?
                var section: Int = accessorySections // Start here since want to skip the accessory sections
                for classArray in classesBySection { // Find the correct class in the 2D array
                    if let r = classArray.index(of: classToDel) {
                        row = r
                        break
                    }
                    section += 1
                }
                
                deleteAll()
                
                if let r = row {
                    // We have a second indexpath now, so we can delete both rows with nice animation
                    self.tableView.beginUpdates()
                    let secondPath = IndexPath(row: r, section: section)
                    self.tableView.deleteRows(at: [indexPath, secondPath], with: .automatic)
                    
                    reloadClassSectionIfNeeded(secondPath)
                    reloadFavoritesSectionIfNeeded(indexPath)
                    
                    self.tableView.endUpdates()
                } else {
                    // Fallback and simply reload the tableView
                    self.tableView.reloadData()
                }
            } else {
                // User is deleting class from normal section, but we also need to remove from favorites section
                if let row = favoritedClasses.index(of: classToDel) {
                    deleteAll()
                    self.tableView.beginUpdates()
                    
                    let secondPath = IndexPath(row: row, section: 0)
                    self.tableView.deleteRows(at: [secondPath, indexPath], with: .automatic)
                    
                    reloadClassSectionIfNeeded(indexPath)
                    reloadFavoritesSectionIfNeeded(secondPath)
                    
                    self.tableView.endUpdates()
                } else {
                    deleteAll()
                    // Fallback and simply reload the tableView
                    self.tableView.reloadData()
                }
            }
        } else {
            self.tableView.beginUpdates()
            deleteAll()
            // If were in the search controller also remove this class from the filtered classes array
            // Since this array is just a flat copy of classesBySection, but hasn't been updated when deleting
            if isSearchActive {
                filteredClasses.remove(at: indexPath.row)
            }
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
            reloadClassSectionIfNeeded(indexPath)
            
            self.tableView.endUpdates()
        }
        
        self.reloadEmptyState()
        
        // Update detail if needed
        if shouldUpdateDetail {
            detailController?.classObj = nil
            detailController?.updateUI()
        }
        else {
            detailController?.updateUI()
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
            self.presentDeleteAlert(at: path)
        })
        
        deleteAction.backgroundColor = UIColor.warning
        
        
        return [deleteAction, editAction, favoriteAction]
    }
    
    /// Updates a classes favorite state at the specified index path
    private func updateFavoriteState(at indexPath: IndexPath) {
        let realm = try! Realm()
        let classAtPath = self.classObj(at: indexPath)
        
        if classAtPath.isFavorite {
            // Remove from favorites section
            if let index = favoritedClasses.index(of: classAtPath) {
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                // Update property in realm, which will also remove it from the favoritedClasses array
                try! realm.write {
                    classAtPath.isFavorite = false
                }
                self.tableView.endUpdates()
            } else {
                // Fallback and just reload the tableview
                self.tableView.reloadData()
            }
        } else { // Add to favorites section
            // Update property in realm which will add class to favoritedClasses array
            try! realm.write {
                classAtPath.isFavorite = true
            }
            // Find index of class since its now in the favoritedClasses array
            if let index = favoritedClasses.index(of: classAtPath) {
                self.tableView.beginUpdates()
                if favoritedClasses.count - 1 == 0 {
                    // This section was previously empty, thus has no header, reload entire seciton
                    self.tableView.reloadSections(IndexSet.init(integer: 0), with: .automatic)
                    self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                } else {
                    self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
                
                self.tableView.endUpdates()
            } else {
                // Fallback and just reload tableview
                self.tableView.reloadData()
            }
        }
        
        // TODO: Test code, remove this
        let snack = LPSnackbar(title: "Favorited", buttonTitle: nil, displayDuration: nil)
        snack.show()
        snack.bottomSpacing = (tabBarController?.tabBar.frame.height ?? 0 ) + 8.0
        snack.view.backgroundColor = UIColor.lightBackground
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
            detailController?.updateUI()
        }
    }
    
    func didFinishCreating(newClass classObj: Class) {
        guard let section = self.section(forMatchingSemester: classObj.semester!),
            let row = classesBySection[section].index(of: classObj) else {
                
                print("Couldnt get index for newly created class object")
                return
        }
        
        let indexPath: IndexPath = IndexPath(row: row, section: section + accessorySections)
        
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
