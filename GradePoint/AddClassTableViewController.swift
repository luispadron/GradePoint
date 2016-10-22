//
//  AddClassTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 10/15/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class AddClassTableViewController: UITableViewController, UIRubricViewDelegate {
    
    lazy var rubricViews = [UIRubricView]()
    var numOfRubricViews = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.separatorColor = UIColor.tableViewSeperator
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // - MARK: - Table View Methods
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 44))
        mainView.backgroundColor = UIColor.lightBg
        
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: mainView.bounds.size.width, height: 44))
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor.textMuted
        label.backgroundColor = UIColor.lightBg
        mainView.addSubview(label)
        
        switch section {
        case 0:
            label.text = "BASIC INFORMATION"
            return mainView
        case 1:
            label.text = "GRADE RUBRIC"
            return mainView
        default:
            return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // This will just be static 2, since only want Name and Term
            return 2
        case 1:
            // This will increase as user adds more rubrics (starts @ 1)
            return numOfRubricViews
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 44
        case 1:
            return 70
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // If in first section use the basic info cell
        // Else use the rubric cell and cast
        
        // Add a clear selected view
        let emptyView = UIView()
        emptyView.backgroundColor = UIColor.darkBg
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicInfoCell", for: indexPath) as! BasicInformationTableViewCell
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "rubricCell", for: indexPath) as! RubricTableViewCell
            cell.selectedBackgroundView = emptyView
            cell.rubricView.delegate = self
            addViewToArray(cell.rubricView)
            return cell
        }
        
        return UITableViewCell()
    }
    
    // - MARK: Rubric View Delegate
    
    func plusButtonTouched(_ view: UIRubricView, forState state: UIRubricViewState) {
        switch state {
        case .collapsed:
            // Handle user cancelling that item
            handleCloseState(withRubricView: view)
        case .open:
            // Handle user wanting to add a grade section
            handleOpenState(withRubricView: view)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // - MARK: IBActions
    
    @IBAction func onCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSave(_ sender: AnyObject) {
    }
    
    // - MARK: Helper Methods
    
    func addViewToArray(_ view: UIRubricView) {
        if rubricViews.contains(view) { return }
        else { rubricViews.append(view) }
    }

    func handleOpenState(withRubricView view: UIRubricView) {
        // If it's not the last rubric view then dont add another since we only want to 
        // add a new rubric input view when ever the use has exhausted all the others
        if view !== rubricViews[rubricViews.count - 1] { return }
        
        // Last rubric view, lets create another one for the use incase they want to enter something
        let path = IndexPath(row: numOfRubricViews, section: 1)
        self.numOfRubricViews += 1
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [path], with: .bottom)
            self.tableView.endUpdates()
            self.tableView.scrollToRow(at: path, at: .bottom, animated: true)
        }
    }
    
    func handleCloseState(withRubricView view: UIRubricView) {
        guard let row = rubricViews.index(of: view), numOfRubricViews > 1 else {
            print("FATAL ERROR: Could not find rubric view to delete")
            return
        }
        
        self.numOfRubricViews -= 1
        rubricViews.remove(at: row)
        
        let path = IndexPath(row: row, section: 1)
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [path], with: .bottom)
            self.tableView.endUpdates()
        }
    }
}
