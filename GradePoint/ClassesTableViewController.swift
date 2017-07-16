//
//  ClassesTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 7/16/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

class ClassesTableViewController: UITableViewController {
    
    // MARK: Properties
    
    private var notificationTokens: [NotificationToken] = [NotificationToken]()
    
    private var semesters: [Semester] {
        get {
            return generateSemesters()
        }
    }
    
    private var classes: [Results<Class>] = [Results<Class>]()
    
    // MARK: View Handeling
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup delegation a
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        splitViewController?.delegate = self
        splitViewController?.preferredDisplayMode = .allVisible
        tableView.scrollsToTop = true
        
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
    }
    
    // MARK: Table View Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return classes.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return classes[section].count > 0 ? 44 : 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sem = semesters[section]
        return "\(sem.term) \(sem.year)"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.tintColor = UIColor.tableViewHeader
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        header.textLabel?.textColor = UIColor.unselected
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell", for: indexPath) as! ClassTableViewCell
        let classObj = self.classObj(at: indexPath)
        cell.classTitleLabel.text = classObj.name
        cell.classDateLabel.text = "\(classObj.semester!.term) \(classObj.semester!.year)"
        cell.ribbonColor = classObj.color
        return cell
    }
    
    // MARK: Helper Methods
    
    /// This generates all of the possible Semester combinations, this array will be the sections for the table view
    private func generateSemesters() -> [Semester] {
        let terms: [String]
        
        /// Load semesters from user defaults, if for some reason this isnt saved, fall back to default semesters
        if let t = UserDefaults.standard.stringArray(forKey: UserDefaultKeys.terms.rawValue) {
            terms = t
        } else {
            print("WARNING: Something went wrong when loading semesters from UserDefaults, loading default set instead.")
            terms = ["Spring", "Summer", "Fall", "Winter"]
        }
        
        let years = UISemesterPickerView.createArrayOfYears()
        var results = [Semester]()
        
        for year in years {
            for term in terms {
                results.append(Semester(withTerm: term, andYear: year))
            }
        }
        return results
    }
    
    /// Loads all the Class objects in Realm into the `classes` array, grouped by their semester and sorted by their date.
    private func loadClasses() {
        let realm = DatabaseManager.shared.realm
        let all = realm.objects(Class.self)
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
            case .error(let error): fatalError("Error in Realm notification change.\n \(error)")
            }
        }
        notificationTokens.append(notification)
    }
    
    /// Returns a class object at a specified index path
    private func classObj(at path: IndexPath) -> Class {
        return classes[path.section][path.row]
    }
    
    // MARK: Deinit
    
    deinit {
        notificationTokens.forEach {
            $0.stop()
        }
    }
}

// MARK: Split View Delegation

extension ClassesTableViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController:UIViewController,
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
