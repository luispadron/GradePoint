//
//  DetailViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 10/12/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class ClassesViewController: UITableViewController {

    // MARK: - Properties
    
    var detailItem: Class? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    
    // MARK: - Overrides 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
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
            print(detail.className)
        }
    }


}

