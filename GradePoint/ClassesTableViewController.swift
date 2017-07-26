//
//  ClassesTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 7/16/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift
import UIEmptyState
import LPSnackbar

class ClassesTableViewController: UITableViewController {
    
    // MARK: Properties
    
    /// Any Realm notification tokens that are active
    private var notificationTokens: [NotificationToken] = [NotificationToken]()
    
    /// The semesters, which are the sections for the tableview
    private var semesters: [Semester] {
        get {
            return generateSemesters()
        }
    }
    
    /// All the classes saved in Realm, grouped by their semesters
    private var classes: [Results<Class>] = [Results<Class>]()
    
    /// Classes filtered by search text from the `searchController`
    private var filteredClasses: Results<Class>?
    
    /// The search controller used to filter the table view
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.delegate = self
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.placeholder = "Search"
        return controller
    }()
    
    /// Returns whether the search controller is active or not
    private var isSearchActive: Bool {
        return searchController.isActive && searchController.searchBar.text != ""
    }
    
    // MARK: View Handeling
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch UIColor.theme {
        case .dark: navigationController?.navigationBar.barStyle = .black
        case .light: navigationController?.navigationBar.barStyle = .default
        }

        // Setup search bar and titles
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.searchController = searchController
        } else {
            searchController.searchBar.barTintColor = UIColor.background
            tableView.contentOffset = CGPoint(x: 0, y: tableView.contentOffset.y + searchController.searchBar.frame.height)
            tableView.tableHeaderView = searchController.searchBar
        }
        
        splitViewController?.delegate = self
        splitViewController?.preferredDisplayMode = .allVisible
        tableView.scrollsToTop = true
        emptyStateDelegate = self
        emptyStateDataSource = self
        
        // Remove seperator lines from empty cells, and remove white background around navbars
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorColor = UIColor.tableViewSeperator
        tableView.backgroundView = UIView()
        
        // Setup tableview estimates
        tableView.estimatedRowHeight = 60
        tableView.estimatedSectionHeaderHeight = 44
        tableView.estimatedSectionFooterHeight = 0
        
        // Get all classes on load
        loadClasses()
        
        // Add notifications for Class object changes
        for (i, objs) in classes.enumerated() {
            registerNotifications(for: objs, in: i)
        }
        
        // Listen to semester update notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.semestersDidUpdate),
                                               name: semestersUpdatedNotification, object: nil)
        // Listen to theme changes notificaitons
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUIForThemeChanges),
                                               name: themeUpdatedNotification, object: nil)
        // Add 3D touch support to this view
        if traitCollection.forceTouchCapability == .available { registerForPreviewing(with: self, sourceView: self.view) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadEmptyState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        clearsSelectionOnViewWillAppear = splitViewController?.isCollapsed ?? false
    }
    
    // MARK: Table View Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isSearchActive {
            return 1
        } else {
            return classes.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive {
            return filteredClasses?.count ?? 0
        } else {
            return classes[section].count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard !isSearchActive else {
            return 0
        }
        
        return classes[section].count > 0 ? 44 : 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Favorites"
        } else {
            guard section - 1 < semesters.count else { return "Unknown Semester"}
            let sem = semesters[section - 1]
            return "\(sem.term) \(sem.year)"
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.tintColor = UIColor.tableViewHeader
        header.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        header.textLabel?.textColor = UIColor.tableViewHeaderText
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell", for: indexPath) as! ClassTableViewCell
        let classObj = self.classObj(at: indexPath)
        cell.classTitleLabel.text = classObj.name
        cell.ribbonColor = classObj.color
        // Set the label text colors
        cell.classTitleLabel.textColor = UIColor.mainTextColor()
        cell.classDetailLabel.textColor = UIColor.secondaryTextColor()

        if classObj.isInProgress && classObj.assignments.count  == 0 {
            // Since no assignments, new class, just say A
            cell.classDetailLabel.text = "Grade: A"
        } else {
            guard let grade = classObj.grade else {
                cell.classDetailLabel.text = nil
                return cell
            }
            cell.classDetailLabel.text = "Grade: " + grade.gradeLetter
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if classObj(at: indexPath).isInProgress {
            performSegue(withIdentifier: .showDetail, sender: indexPath)
        } else {
            performSegue(withIdentifier: .showPreviousDetail, sender: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard !isSearchActive else { return false }
        return true
    }
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favorite = UIContextualAction(style: .normal, title: "Favorite", handler: { action, view, finished in
            finished(true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.didFavoriteClass(at: indexPath)
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
        let editAction = UITableViewRowAction(style: .normal, title: "Edit", handler: { [weak self] _, path in
            self?.performSegue(withIdentifier: .addEditClass, sender: path)
        })
        
        editAction.backgroundColor = UIColor.info
        
        
        let favoriteAction = UITableViewRowAction(style: .normal, title: "Favorite", handler: { [weak self] _, path in
            self?.didFavoriteClass(at: path)
        })
        
        favoriteAction.backgroundColor = UIColor.goldenYellow
        
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { [weak self] _, path in
            self?.handleDelete(at: path)
        })
        
        deleteAction.backgroundColor = UIColor.warning
        
        return [editAction, favoriteAction, deleteAction]
    }
    
    // MARK: Helper Methods
    
    /// This generates all of the possible Semester combinations, this array will be the sections for the table view
    private func generateSemesters() -> [Semester] {
        let terms: [String]
        
        /// Load semesters from user defaults, if for some reason this isnt saved, fall back to default semesters
        if let t = UserDefaults.standard.stringArray(forKey: userDefaultTerms) {
            terms = t
        } else {
            print("WARNING: Something went wrong when loading semesters from UserDefaults, loading default set instead.")
            terms = ["Spring", "Summer", "Fall", "Winter"]
        }
        
        let years = UISemesterPickerView.createArrayOfYears()
        var results = [Semester]()
        
        for year in years {
            for term in terms {
                results.append(Semester(term: term, year: year))
            }
        }
        return results
    }
    
    /// Loads all the Class objects in Realm into the `classes` array, grouped by their semester and sorted by their date.
    private func loadClasses() {
        let realm = DatabaseManager.shared.realm
        let all = realm.objects(Class.self)
        // First append results of classes being favorited in row 0 of the 2D array
        self.classes.append(all.filter("isFavorite == %@", true))
        // The rest of the arrays inside the `classes` array will be grouped by their semester
        semesters.forEach {
            let classes = all.filter("semester.term == %@ AND semester.year == %@", $0.term, $0.year)
            self.classes.append(classes)
        }
    }
    
    /// Creates realm notifications for each array of classes in the `classes` array
    private func registerNotifications(for results: Results<Class>, in section: Int) {
        let notification = results.addNotificationBlock { [weak self] (changes) in
            guard let tableView = self?.tableView else { return }
            guard !(self?.isSearchActive ?? false) else {
                tableView.reloadData()
                return
            }
            
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
                self?.reloadEmptyState()
                
                // Also update the detail controller if in split view
                guard let navController = (self?.splitViewController?.viewControllers.last as? UINavigationController),
                    let detailController = navController.childViewControllers.first as? ClassDetailTableViewController
                    else { break }
                
                for index in modifications {
                    let classObj = results[index]
                    if detailController.classObj == classObj {
                        DispatchQueue.main.async {
                            detailController.classObj = classObj
                        }
                    }
                }
                
            case .error(let error): fatalError("Error in Realm notification change.\n \(error)")
                
            }
        }
        
        notificationTokens.append(notification)
    }
    
    /// Returns a class object at a specified index path
    private func classObj(at path: IndexPath) -> Class {
        if isSearchActive {
            return filteredClasses![path.row]
        } else {
            return classes[path.section][path.row]
        }
    }
    
    /// Deletes a class from Realm
    private func deleteClass(_ classObj: Class) {
        // Remove object from Realm
        DatabaseManager.shared.deleteObjects(classObj.rubrics)
        DatabaseManager.shared.deleteObjects(classObj.assignments)
        DatabaseManager.shared.deleteObjects([classObj.semester!, classObj.grade!, classObj])
    }
    
    /// Filters and updates the `filteredClasses` array with the passed in search text
    private func filterClasses(for searchText: String) {
        filteredClasses = DatabaseManager.shared.realm.objects(Class.self).filter("name CONTAINS[cd] %@", searchText)
    }
    
    /// Handles deleting a cell and class object from the table view
    private func handleDelete(at path: IndexPath) {
        let classToDel = classObj(at: path)
        // Create a copy in case the user undoes the deletion
        let copy = classToDel.copy() as! Class
        
        // Set the associated rubric for the assignment to the exact same rubric in the rubrics array
        for assignment in copy.assignments {
            var sameRubric: Rubric?
            for rubric in copy.rubrics {
                if rubric == assignment.rubric {
                    sameRubric = rubric
                    break
                }
            }
            
            assignment.rubric = sameRubric
        }
    
        // Figure out whether we need to update the state of the detail controller or not
        // ONLY done when view controllers are in split view mode
        // If yes then remove the detail controllers classObj, which will cause the view to configure and show correct message
        if classToDel.isInProgress {
            // In progress class
            let navController = (self.splitViewController?.viewControllers.last as? UINavigationController)
            let detailController = navController?.childViewControllers.first as? ClassDetailTableViewController
            if  detailController?.classObj == classToDel {
                detailController?.classObj = nil
            }
        } else {
            // Previous class, different process, just hide all the views and move on
            let navController = (self.splitViewController?.viewControllers.last as? UINavigationController)
            let prevDetailController = navController?.childViewControllers.first as? PreviousClassDetailViewController
            prevDetailController?.toggleViewVisibility(to: false)
        }
        
        // Set is favorites to false, this way it will get removed from the favorites section as well
        DatabaseManager.shared.write {
            classToDel.isFavorite = false
        }

        // Delete from Realm
        deleteClass(classToDel)
    
        reloadEmptyState()
        
        // Present snack bar to allow undo
        let snack = LPSnackbar(title: "Class deleted.", buttonTitle: "UNDO", displayDuration: 3.0)
        snack.viewToDisplayIn = navigationController?.view
        snack.bottomSpacing = (tabBarController?.tabBar.frame.height ?? 0) + 12
        
        snack.show() { [weak self] undone in
            guard undone else { return }
            DatabaseManager.shared.addObject(copy)
            self?.reloadEmptyState()
        }
    }
    
    /// Called whenever a class is favorited. Will update the class in realm and add the appropriate cells to the table view
    private func didFavoriteClass(at path: IndexPath) {
        let classObj = self.classObj(at: path)
        DatabaseManager.shared.write {
            classObj.isFavorite = !classObj.isFavorite
        }
    }

    // MARK: Deinit

    deinit {
        notificationTokens.forEach {
            $0.stop()
        }
        NotificationCenter.default.removeObserver(self)
    }
}

extension ClassesTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText != "" else {
            self.searchController.isActive = false
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
        self.tableView.reloadData()
        self.reloadEmptyState()
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
            guard let indexPath = sender as? IndexPath else { return }
            
            let classItem: Class = classObj(at: indexPath)
            
            let controller = (segue.destination as! UINavigationController).topViewController as! ClassDetailTableViewController
            controller.classObj = classItem
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            
        case .showPreviousDetail:
            guard let indexPath = sender as? IndexPath else { return }
            
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
            
            let screenSize = UIScreen.main.bounds.size
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                controller.preferredContentSize = CGSize(width: screenSize.width / 2, height: screenSize.height / 2)
            } else {
                controller.preferredContentSize = CGSize(width: screenSize.width * 0.65, height: screenSize.height * 0.85)
            }
            
            // Collapse any edit actions for the tableview, so theyre not opened when returning
            tableView.isEditing = false
            
        case .onboarding:
            break
        }
        
        // Remove any searches
        filteredClasses = nil
        searchController.isActive = false
        tableView.reloadData()
    }
}

// MARK: UIEmptyState Data Source & Delegate

extension ClassesTableViewController: UIEmptyStateDataSource, UIEmptyStateDelegate {
    
    // Empty State Data Source
    
    func shouldShowEmptyStateView(for tableView: UITableView) -> Bool {
        // If not items then empty, show empty state
        return DatabaseManager.shared.realm.objects(Class.self).count == 0
    }
    
    var emptyStateTitle: NSAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.mainTextColor(),
                                                   .font: UIFont.systemFont(ofSize: 20)]
        return NSAttributedString(string: "No Classes Added", attributes: attrs)
    }
    
    var emptyStateImage: UIImage? { return #imageLiteral(resourceName: "EmptyClassesIcon") }
    
    var emptyStateButtonTitle: NSAttributedString? {
        let attrs: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.highlight,
                                                   .font: UIFont.systemFont(ofSize: 18)]
        return NSAttributedString(string: "Add a class", attributes: attrs)
    }
    
    var emptyStateButtonImage: UIImage? { return #imageLiteral(resourceName: "ButtonBg") }
    
    var emptyStateButtonSize: CGSize? { return CGSize(width: 160, height: 45) }
    
    var emptyStateViewAnimatesEverytime: Bool { return false }

    var emptyStateViewSpacing: CGFloat { return 20 }

    // Empty State Delegate
    
    func emptyStateViewWillShow(view: UIView) {
        guard let emptyView = view as? UIEmptyStateView else { return }

        // Update tint for button
        emptyView.button.tintColor = .highlight

        // Hide the search controller
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = true
            searchController.isActive = false
        } else {
            searchController.isActive = false
            // Remove from table view header
            tableView.tableHeaderView = nil
        }
    }
    
    func emptyStateViewWillHide(view: UIView) {
        // Re add the search controller
        if #available(iOS 11.0, *) {
            // Nothing to do here
        } else {
            if tableView.tableHeaderView == nil {
                tableView.tableHeaderView = searchController.searchBar
            }
        }
    }
    
    func emptyStatebuttonWasTapped(button: UIButton) {
        self.performSegue(withIdentifier: .addEditClass, sender: button)
    }
}

// MARK: 3D Touch Delegation

extension ClassesTableViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath) else { return nil }
        guard let peekVC = storyboard?.instantiateViewController(withIdentifier: "ClassPeekViewController") as? ClassPeekViewController else { return nil }
        
        // Only allow peeking for in progress classes
        let classObj = self.classObj(at: indexPath)
        guard classObj.isInProgress else { return nil }
        
        peekVC.setUI(for: classObj)
        peekVC.preferredContentSize = CGSize(width: 240.0, height: 240.0)
        peekVC.indexPathForPeek = indexPath
        previewingContext.sourceRect = cell.frame
        
        return peekVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let indexPath = (viewControllerToCommit as? ClassPeekViewController)?.indexPathForPeek else { return }
        self.performSegue(withIdentifier: .showDetail, sender: indexPath)
    }
}

// MARK: Split View Delegation

extension ClassesTableViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController:UIViewController,
                             onto primaryViewController:UIViewController) -> Bool {
        
        guard let detailNavController = secondaryViewController as? UINavigationController else { return true }
        if let detailController = detailNavController.topViewController as? ClassDetailTableViewController {
            // In progress class, only collapse if classObj is nil or invalidated
            return detailController.classObj == nil || (detailController.classObj?.isInvalidated ?? true)
        } else if let prevDetailController = detailNavController.topViewController as? PreviousClassDetailViewController {
            // Previous class, only collapse if views are hidden, if `bgView` is hidden, safe to assume they all are
            return prevDetailController.bgView.isHidden
        }
        
        
        return false
    }
}

/// MARK: Notification methods

extension ClassesTableViewController {
    /// Called whenever semesters are updated inside the `SemesterConfigurationViewController`
    @objc private func semestersDidUpdate(notification: Notification) {
        // Remove all classes and load them again with new semesters
        classes.removeAll()
        loadClasses()
        // Stop & remove all notification tokens
        for (index, token) in notificationTokens.enumerated().reversed() {
            token.stop()
            notificationTokens.remove(at: index)
        }

        // Add notifications for Class object changes
        for (i, objs) in classes.enumerated() {
            registerNotifications(for: objs, in: i)
        }

        reloadEmptyState()
    }

    /// Called whenever the them is updated
    @objc private func updateUIForThemeChanges(notification: Notification) {
        switch UIColor.theme {
        case .dark:
            navigationController?.navigationBar.barStyle = .black
        case .light:
            navigationController?.navigationBar.barStyle = .default
        }

        searchController.searchBar.barTintColor = UIColor.background
        tableView.separatorColor = UIColor.tableViewSeperator

        tableView.reloadData()
        reloadEmptyState()
    }
}
