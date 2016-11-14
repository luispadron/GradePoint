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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set seperator color
        self.tableView.separatorColor = UIColor.tableViewSeperator
        
        // Add tableview header
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 260))
        progressRing.center = view.center
        headerView.addSubview(progressRing)
        self.tableView.tableHeaderView = headerView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
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


    override func viewWillLayoutSubviews() {
        if let headerView = self.tableView.tableHeaderView {
            headerView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 260)
            progressRing.center = headerView.center
        }
        
        super.viewWillLayoutSubviews()
    }
}

