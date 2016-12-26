//
//  AddEditAssignmentTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 12/12/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class AddEditAssignmentTableViewController: UITableViewController {

    // MARK: - Properties
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    var parentClass: Class!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Remove seperator color, by making it look like table view
        self.tableView.separatorColor = UIColor.lightBg
    }
    

    // MARK: - Table view

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 44))
        mainView.backgroundColor = UIColor.tableViewHeader
        
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: mainView.bounds.size.width, height: 44))
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.unselected
        label.backgroundColor = UIColor.tableViewHeader
        mainView.addSubview(label)
        
        switch section {
        case 0:
            label.text = "Basic Info"
            return mainView
        case 1:
            label.text = "Assignment Score"
            return mainView
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: Actually do something here
        
        return UITableViewCell()
    }

    // MARK: - IBActions
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onDone(_ sender: UIBarButtonItem) {
    }

}
