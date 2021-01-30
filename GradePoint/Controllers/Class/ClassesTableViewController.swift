//
//  ClassesTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 7/16/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift
import LPSnackbar

class ClassesTableViewController: UITableViewController, RealmTableView {
    // Conformance to RealmTableView
    typealias RealmObject = Class
    var realmData: [[Class]] {
        get { return classes }
        set { classes = newValue }
    }
    
    private var classDeletionQueue: [Class: LPSnackbar] = [:]
    var deletionQueue: [Class: LPSnackbar] {
        get { return classDeletionQueue }
        set { classDeletionQueue = newValue }
    }

    var preferedSnackbarBottomSpacing: CGFloat {
        return self.tabBarController!.tabBar.frame.height + 12
    }
    
    // MARK: Properties

    /// The semesters, which are the sections for the tableview
    private var semesters: [Semester] = []
    
    /// All the classes saved in Realm, grouped by their semesters
    private var classes: [[Class]] = []
    
    /// Classes filtered by search text from the `searchController`
    private var filteredClasses: Results<Class>?
    
    /// The search controller used to filter the table view
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.delegate = self
        controller.searchBar.placeholder = "Search"
        return controller
    }()
    
    /// Returns whether the search controller is active or not
    private var isSearchActive: Bool {
        return searchController.isActive && searchController.searchBar.text != ""
    }

    private var fromIndexPath: IndexPath? = nil
    private var toIndexPath: IndexPath? = nil

    private var gradeRubricNotifToken: NotificationToken?

    private var hasPresentedGradeLetterSnack: Bool = false
    
    // MARK: View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barStyle = ApplicationTheme.shared.navigationBarStyle

        // Setup search bar and titles
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationItem.searchController = searchController
        } else {
            self.searchController.searchBar.barTintColor = ApplicationTheme.shared.backgroundColor
            self.tableView.contentOffset = CGPoint(x: 0, y: tableView.contentOffset.y + searchController.searchBar.frame.height)
            self.tableView.tableHeaderView = searchController.searchBar
        }
        
        self.splitViewController?.delegate = self
        self.splitViewController?.preferredDisplayMode = .allVisible
        self.tableView.scrollsToTop = true
        // Remove seperator lines from empty cells, and remove white background around navbars
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = ApplicationTheme.shared.tableViewSeperatorColor
        self.tableView.backgroundView = UIView()
        
        // Setup tableview estimates
        self.tableView.estimatedRowHeight = 60
        self.tableView.estimatedSectionHeaderHeight = 44
        self.tableView.estimatedSectionFooterHeight = 0
        
        // Get all classes on load
        self.semesters = generateSemesters()
        self.loadClasses()
        
        // Listen to semester update notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUIForRemoteClassChange),
                                               name: kRemoteClassChangeNotification, object: nil)
        // Listen to theme changes notificaitons
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateUIForThemeChanges),
                                               name: kThemeUpdatedNotification, object: nil)

        // Add 3D touch support to this view
        if self.traitCollection.forceTouchCapability == .available { self.registerForPreviewing(with: self, sourceView: self.view) }

        // Listen to changes to grade rubric
        self.gradeRubricNotifToken = DatabaseManager.shared.realm.objects(GradeRubric.self).observe({ _ in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.separatorColor = ApplicationTheme.shared.tableViewSeperatorColor
        self.view.backgroundColor = ApplicationTheme.shared.backgroundColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.clearsSelectionOnViewWillAppear = splitViewController?.isCollapsed ?? false
        self.setNeedsStatusBarAppearanceUpdate()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dequeAndDeleteObjects()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ApplicationTheme.shared.statusBarStyle
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
        header.tintColor = ApplicationTheme.shared.tableViewHeaderColor
        header.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        header.textLabel?.textColor = ApplicationTheme.shared.tableViewHeaderTextColor
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell", for: indexPath) as! ClassTableViewCell
        let classObj = self.classObj(at: indexPath)
        cell.classTitleLabel.text = classObj.name
        cell.ribbonColor = classObj.color
        // Set the label text colors
        cell.classTitleLabel.textColor = ApplicationTheme.shared.mainTextColor()
        cell.classDetailLabel.textColor = ApplicationTheme.shared.secondaryTextColor()

        if classObj.isInProgress && classObj.assignments.count  == 0 {
            // Since no assignments, new class, just say A
            cell.classDetailLabel.text = "Grade: A"
        } else if let grade = classObj.grade {
            cell.classDetailLabel.text = "Grade: " + grade.gradeLetter
            // Present a warning to user that their percentage configuration is invalid since we have an invalid letter grade
            if grade.gradeLetter == "?" {
                self.presentGradeLetterSnack()
            }
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
        if let t = UserDefaults.standard.stringArray(forKey: kUserDefaultTerms) {
            terms = t
        } else {
            print("WARNING: Something went wrong when loading semesters from UserDefaults, loading/setting default terms instead.")
            terms = ["Spring", "Summer", "Fall", "Winter"]
            UserDefaults.standard.set(terms, forKey: kUserDefaultTerms)
        }
        
        let years = Semester.possibleYears
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
        self.classes.append(Array(all.filter("isFavorite == %@", true)))
        // The rest of the arrays inside the `classes` array will be grouped by their semester
        semesters.forEach {
            let classes = all.filter("semester.term == %@ AND semester.year == %@", $0.term, $0.year)
            self.classes.append(Array(classes))
        }
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


    private func handleDelete(at path: IndexPath) {
        let classToDel = classObj(at: path)

        // Figure out whether we need to update the state of the detail controller or not
        // ONLY done when view controllers are in split view mode
        // If yes then remove the detail controllers classObj, which will cause the view to configure and show correct message
        if classToDel.isInProgress {
            // In progress class
            let navController = (self.splitViewController?.viewControllers.last as? UINavigationController)
            let detailController = navController?.children.first as? ClassDetailTableViewController
            if  detailController?.classObj == classToDel {
                detailController?.classObj = nil
            }
        } else {
            // Previous class, different process, just hide all the views and move on
            let navController = (self.splitViewController?.viewControllers.last as? UINavigationController)
            let prevDetailController = navController?.children.first as? PreviousClassDetailViewController
            prevDetailController?.toggleViewVisibility(to: false)
        }

        // If class is a favorite
        if path.section == 0 {
            var regSection: Int = 0
            for (i, arr) in classes.enumerated() { if arr.firstIndex(of: classToDel) != nil && i != 0 { regSection = i; break } }

            // Delete object in favorites section
            self.deleteCellWithObject(classToDel, section: path.section,
                                      snackTitle: "Class deleted", buttonTitle: "UNDO",
                                      allowsUndo: false, completion: nil)
            // Delete object in normal section
            self.deleteCellWithObject(classToDel, section: regSection,
                                      snackTitle: "Class deleted", buttonTitle: "UNDO",
                                      allowsUndo: true, completion: { [weak self] (undone, obj) in
                guard !undone else { return }
                self?.deleteClass(obj)
            })
        } else if classToDel.isFavorite {
            // Delete object in normal section
            self.deleteCellWithObject(classToDel, section: path.section,
                                      snackTitle: "Class deleted", buttonTitle: "UNDO",
                                      allowsUndo: true) { [weak self] undone, classObj in
                guard !undone else { return }
                self?.deleteClass(classObj)
            }
            // Delete object in favorites section
            self.deleteCellWithObject(classToDel, section: 0,
                                      snackTitle: "Class deleted", buttonTitle: "UNDO",
                                      allowsUndo: false, completion: nil)
        } else {
            // Delete object in normal section
            self.deleteCellWithObject(classToDel, section: path.section,
                                      snackTitle: "Class deleted", buttonTitle: "UNDO",
                                      allowsUndo: true) { [weak self] undone, classObj in
                guard !undone else { return }
                self?.deleteClass(classObj)
            }
        }

        // Unfavorite the class if deleted
        DatabaseManager.shared.write {
            classToDel.isFavorite = false
        }
    }

    /// Called whenever a class is favorited. Will update the class in realm and add the appropriate cells to the table view
    private func didFavoriteClass(at path: IndexPath) {
        let classObj = self.classObj(at: path)

        if classObj.isFavorite {
            // Unfavorite
            self.deleteCellWithObject(classObj, section: 0,
                                      snackTitle: "Class deleted.", buttonTitle: "UNDO",
                                      allowsUndo: false, completion: nil)
        } else {
            self.addCellWithObject(classObj, section: 0)
        }

        DatabaseManager.shared.write {
            classObj.isFavorite = !classObj.isFavorite
        }
    }
    
    /// Conformace for RealmTableView
    func deleteObject(_ object: Class) {
        deleteClass(object)
    }

    /// Presents a warning message to the user about an invalid grade letter
    private func presentGradeLetterSnack() {
        guard !self.hasPresentedGradeLetterSnack else { return }

        let snack = LPSnackbar(title: "Warning: Grade percentage\nconfiguration is invalid", buttonTitle: "FIX")
        snack.view.titleLabel.numberOfLines = 0
        snack.view.titleLabel.sizeToFit()
        snack.height = snack.view.titleLabel.frame.height + 10
        snack.bottomSpacing = self.preferedSnackbarBottomSpacing
        snack.show(displayDuration: 5, animated: true) { fixTapped in
            if fixTapped {
                let window = (UIApplication.shared.delegate as! AppDelegate).window
                guard let tabBar = window?.rootViewController as? UITabBarController,
                    tabBar.children.count > 2,
                    let settingsVc = tabBar.children[2].children.first as? SettingsTableViewController else {
                        print("WARNING: Tried to find SettingsTableViewController but was not able.")
                        return
                }

                // Perform segue and show percentage configuration controller
                tabBar.selectedIndex = 2
                settingsVc.performSegue(withIdentifier: "showPercentageConfigurationController", sender: nil)
            }
        }

        self.hasPresentedGradeLetterSnack = true
    }
    
    // MARK: Deinit

    deinit {
        NotificationCenter.default.removeObserver(self)
        self.gradeRubricNotifToken?.invalidate()
    }
}

// MARK: Searchbar delegate

extension ClassesTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Update classes array to filter for name
        self.filterClasses(for: searchText)
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchController.isActive = false
        self.tableView.reloadData()
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
            controller.classListener = self
            
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

            controller.listener = self

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

// MARK: AddEditClassDelegation

extension ClassesTableViewController: ClassChangesListener {

    func classWasCreated(_ classObj: Class) {
        self.addCellWithObject(classObj, section: self.semesters.firstIndex(of: classObj.semester!)! + 1)
    }

    func classWasUpdated(_ classObj: Class) {
        let section = semesters.firstIndex(of: classObj.semester!)! + 1
        self.reloadCellWithObject(classObj, section: section)

        // Update detail controller if in Split view/iPad
        // Also update the detail controller if in split view
        guard let navController = self.splitViewController?.viewControllers.last as? UINavigationController else { return }
        if let detailController = navController.children.first as? ClassDetailTableViewController,
            detailController.classObj == classObj {
            // Re-set the object which causes UI to update
            detailController.classObj = classObj
        } else if let detailControl = navController.children.first as? PreviousClassDetailViewController {
            detailControl.className = classObj.name
            detailControl.gradeString = classObj.grade?.gradeLetter
            detailControl.setupUI()
        }
    }

    func classSemesterWasUpdated(_ classObj: Class, from sem1: Semester, to sem2: Semester) {
        let fromSection = semesters.firstIndex(of: sem1)! + 1
        let toSection = semesters.firstIndex(of: sem2)! + 1
        let oldPath = IndexPath(row: classes[fromSection].firstIndex(of: classObj)!, section: fromSection)
        let newPath = IndexPath(row: classes[toSection].count, section: toSection)

        self.moveCellWithObject(classObj, from: oldPath, to: newPath)
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

// MARK: Notification methods

extension ClassesTableViewController {
    /// Called whenever semesters are updated inside the `SemesterConfigurationViewController`
    @objc private func updateUIForRemoteClassChange(notification: Notification) {
        // Remove all classes and load them again
        classes.removeAll()
        semesters.removeAll()
        semesters = generateSemesters()
        loadClasses()
        self.tableView.reloadData()
    }

    /// Called whenever the them is updated
    @objc private func updateUIForThemeChanges(notification: Notification) {
        self.navigationController?.navigationBar.barStyle = ApplicationTheme.shared.navigationBarStyle

        self.searchController.searchBar.barTintColor = ApplicationTheme.shared.backgroundColor
        self.tableView.separatorColor = ApplicationTheme.shared.tableViewSeperatorColor

        self.tableView.reloadData()
    }
}
