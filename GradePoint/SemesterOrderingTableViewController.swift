//
//  SemesterOrderingTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 6/13/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

class SemesterOrderingTableViewController: UITableViewController {

    var semesters = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Footer customization & seperator colors
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = UIColor.tableViewSeperator
    
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.title = "Semester Ordering"
    
        // Load the semesters from user defaults
        if let terms = UserDefaults.standard.stringArray(forKey: UserDefaultKeys.terms.rawValue) {
            semesters = terms
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Save any ordering
        UserDefaults.standard.set(semesters, forKey: UserDefaultKeys.terms.rawValue)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return semesters.count
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "semesterCell", for: indexPath)
        cell.backgroundColor = UIColor.lightBackground
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = semesters[indexPath.row]
        return cell
    }
    
    
 
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
 
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    
 
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let moved = semesters[fromIndexPath.row]
        semesters.remove(at: fromIndexPath.row)
        semesters.insert(moved, at: to.row)
    }
    

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
 


}
