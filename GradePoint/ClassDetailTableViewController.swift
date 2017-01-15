//
//  DetailViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 10/12/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift
import UICircularProgressRing

class ClassDetailTableViewController: UITableViewController {

    // MARK: - Properties
    
    var realm = try! Realm()
    var notificationToken: NotificationToken?
    
    @IBOutlet var progressRing: UICircularProgressRingView!
    
    var detailItem: Class? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the view for load
        configureView()
        
        // Add notification block
        notificationToken = realm.addNotificationBlock {_,_ in 
            self.tableView.reloadData()
        }
        
        let view = UIView()
        view.addSubview(progressRing)
        self.tableView.tableHeaderView = view
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set seperator color
        self.tableView.separatorColor = UIColor.tableViewSeperator
    }
    
    // MARK: - TableView Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return detailItem?.rubrics.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rubrics = detailItem?.rubrics, let parentClass = detailItem else {
            print("Could not get number rubrics for tableView")
            return 0
        }
        
        let rubricForSection = rubrics[section]
        let assignmentsForSection = parentClass.assignments.filter("associatedRubric =  %@", rubricForSection)
        
        return assignmentsForSection.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let rubrics = detailItem?.rubrics, let parentClass = detailItem else {
            print("Could not get number rubrics for tableView")
            return 0
        }
        
        let rubricForSection = rubrics[section]
        let assignmentForSection = parentClass.assignments.filter("associatedRubric = %@", rubricForSection)
        
        return assignmentForSection.count > 0 ? 44 : 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let rubrics = detailItem?.rubrics else {
            print("Error getting rubrics for header view")
            return nil
        }
        // Create the correct headerView for the section
        let rubricForSection = rubrics[section]
        
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 44))
        mainView.backgroundColor = UIColor.tableViewHeader
        
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: mainView.bounds.size.width, height: 44))
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.unselected
        label.backgroundColor = UIColor.tableViewHeader
        mainView.addSubview(label)
        
        // Set the correct label text
        label.text = "\(rubricForSection.name)"
        
        return mainView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rubrics = detailItem?.rubrics, let parentClass = detailItem else {
            print("Error couldn't get rubrics or parentclass in cellForRow")
            return UITableViewCell()
        }
        
        let rubricForSection = rubrics[indexPath.section]
        let assignment = parentClass.assignments
                                    .filter("associatedRubric = %@", rubricForSection)
                                    .sorted(byProperty: "date", ascending: false)[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "assignmentTableViewCell", for: indexPath) as! AssignmentTableViewCell
        
        cell.nameLabel.text = assignment.name
        cell.scoreLabel.text = "Score: \(assignment.score)"
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        cell.dateLabel.text = "Date: " + formatter.string(from: assignment.date)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: { [unowned self] action, indexPath in
            self.deleteAssignment(at: indexPath)
        })
        deleteAction.backgroundColor = UIColor.sunsetOrange
        
        return [deleteAction]
    }
    
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let id = segue.identifier else { return }
        
        if id == "addEditAssignment" {
            // Prepare view for segue
            let vc = (segue.destination as! UINavigationController).topViewController as! AddEditAssignmentTableViewController
            vc.parentClass = self.detailItem
        }
    }
    
    
    // MARK: - Helpers
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            self.title = detail.name
        } else {
            // Figure out if we have any items
            let realm = try! Realm()
            let objs = realm.objects(Class.self)
            if objs.count < 1 { self.title = "Add a Class" }
            else { self.title = "Select a class" }
        }
    }
    
    func deleteAssignment(at indexPath: IndexPath) {
        let rubric = detailItem!.rubrics[indexPath.section]
        let assignment = detailItem!.assignments
                                    .filter("associatedRubric = %@", rubric).sorted(byProperty: "date", ascending: false)[indexPath.row]
        try! realm.write {
            realm.delete(assignment)
        }
        
    }


    override func viewWillLayoutSubviews() {
        if let headerView = self.tableView.tableHeaderView {
            headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 260)
            progressRing.center = headerView.center
        }
        
        super.viewWillLayoutSubviews()
    }
    
    deinit {
        self.notificationToken?.stop()
    }
}

