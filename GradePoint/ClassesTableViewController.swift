//
//  MasterViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 10/12/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

class ClassesTableViewController: UITableViewController {
    
    // MARK: - Realm Properties
    
    var realm = try! Realm()
    var notificationToken: NotificationToken?
    
    var detailViewController: ClassesViewController? = nil
    
    lazy var semestersForSections: [Semester] = {
        // Returns a uniquely sorted array of Semesters, these will be our sections for the tableview
        return Array(self.realm.objects(Semester.self).sorted(byProperty: "year", ascending: false)).unique()
    }()
    
    var classesBySection = [Results<Class>]()
    
    // MARK: Properties
    
    var lastCountOfSections = 0

    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        // Create Realm notification
        setupRealmNotifications()
        // Create the 2D array of Class objects, segmented by their appropriate section in the tableview
        updateClassesBySection()
        tableView.reloadData()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ClassesViewController
            
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
        return semestersForSections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classesBySection[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let semForSection = semestersForSections[section]
        
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 44))
        mainView.backgroundColor = UIColor.lightBg
        
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: mainView.bounds.size.width, height: 44))
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.unselected
        label.backgroundColor = UIColor.lightBg
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Set the detail item
        self.detailViewController?.detailItem = classObj(forIndexPath: indexPath)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Grab the objects to delete from DB, sincce realm doesnt delete associated objects 
            let classToDel = classObj(forIndexPath: indexPath)
            let rubricsToDel = classToDel.rubrics
            let semesterToDel = classToDel.semester!
            
            try! realm.write {
                realm.delete(rubricsToDel)
                realm.delete(semesterToDel)
                realm.delete(classToDel)
            }
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let classItem = classObj(forIndexPath: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! ClassesViewController
                controller.detailItem = classItem
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "addClass" {
            let controller = segue.destination as! UINavigationController
            controller.preferredContentSize = CGSize(width: 500, height: 600)
        }
    }
    
    // MARK: - Helpers
    
    func updateClassesBySection() {
        classesBySection.removeAll()
        for semester in semestersForSections {
            let unsorted = realm.objects(Class.self).filter("semester.term == %@ AND semester.year == %@", semester.term, semester.year)
            let sorted = unsorted.sorted(byProperty: "year", ascending: false)
            classesBySection.append(sorted)
        }
    }
    
    
    // Sets up a notification on the Realm database, this block is called whenever 
    // A new class is created/delted/etc..
    func setupRealmNotifications() {
        notificationToken = realm.addNotificationBlock({ [unowned self] (note, realm) in
            // Update the section
            self.lastCountOfSections = self.semestersForSections.count
            self.semestersForSections = Array(self.realm.objects(Semester.self).sorted(byProperty: "year", ascending: false)).unique()
            
            if self.lastCountOfSections < self.semestersForSections.count || self.lastCountOfSections > self.semestersForSections.count {
                // New section has been added, 2D array of classes must be updated to include new object
                print("Updating")
                self.updateClassesBySection()
            }
            self.tableView.reloadData()
        })
    }
    
    /// Returns a classObj for the sent in index path, used for tableview methods
    func classObj(forIndexPath indexPath: IndexPath) -> Class {
        return classesBySection[indexPath.section][indexPath.row]
    }
    
    // Stop notifications
    deinit {
        notificationToken?.stop()
    }
}

