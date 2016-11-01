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
    
    var realm = try! Realm()
    var notifToken: NotificationToken?
    
    var detailViewController: ClassesViewController? = nil
    
    lazy var classes: Results<Class> = { self.realm.objects(Class.self) }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        // Create Realm notification
        setupRealmNotifications()
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ClassesViewController
            
            // Set the initial detailItem
            // TODO: Add support for saving of last selected item and loading that initially
            if classes.count > 0 { detailViewController?.detailItem = classes[0] }
            else { detailViewController?.detailItem = nil }
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 44))
        mainView.backgroundColor = UIColor.lightBg
        
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: mainView.bounds.size.width, height: 44))
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.unselected
        label.backgroundColor = UIColor.lightBg
        mainView.addSubview(label)
        label.text = "Classes"
        return mainView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClassCell", for: indexPath) as! ClassTableViewCell
        
        let classObj = classes[indexPath.row]
        
        // Set the cells associated class, all UI updates are done in the ClassTableViewCell class
        cell.classObj = classObj
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < classes.count else {
            fatalError("Selected row that was not inside of class array??")
        }
        
        // Set the detail item
        self.detailViewController?.detailItem = classes[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Grab the objects to delete from DB, sincce realm doesnt delete associated objects 
            let classToDel = classes[indexPath.row]
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
                let object = classes[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! ClassesViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "addClass" {
            let controller = segue.destination as! UINavigationController
            controller.preferredContentSize = CGSize(width: 500, height: 600)
        }
    }
    
    // MARK: - Helpers
    
    func setupRealmNotifications() {
        notifToken = classes.addNotificationBlock({ [weak self] (changes: RealmCollectionChange) in
            guard let tbView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated
                tbView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tbView.beginUpdates()
                tbView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                tbView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .automatic)
                tbView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                tbView.endUpdates()
            case .error(let error):
                fatalError("Error in tableview update inside of \(ClassesTableViewController.self)\nError is \(error)")
            }
        })
    }
    
    // Stop notifications
    deinit {
        notifToken?.stop()
    }
}

