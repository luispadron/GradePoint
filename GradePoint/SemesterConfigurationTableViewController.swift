//
//  SemesterConfigurationTableViewController
//  GradePoint
//
//  Created by Luis Padron on 6/13/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

class SemesterConfigurationTableViewController: UITableViewController {

    var semesters = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        
        // Footer customization & seperator colors
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = UIColor.tableViewSeperator
    
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.title = "Semesters"
    
        // Load the semesters from user defaults
        if let terms = UserDefaults.standard.stringArray(forKey: UserDefaultKeys.terms.rawValue) {
            semesters = terms
        }
        
        let text = "\n\nHere you can add and rearrange semesters.\nChanges will be reflected when sorting and adding classes.\n\n"
        let label = UILabel()
        label.attributedText = NSAttributedString(string: text,
                                                  attributes: [.font: UIFont.preferredFont(forTextStyle: .body),
                                                                .foregroundColor: UIColor.mainTextColor()])
        label.textAlignment = .center
        label.resizeToFitText()
        self.tableView.tableHeaderView = label
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Save any ordering
        UserDefaults.standard.set(semesters, forKey: UserDefaultKeys.terms.rawValue)
        // Notify that semesters have been updated
        NotificationCenter.default.post(Notification(name: semestersUpdatedNotification))
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
        cell.textLabel?.textColor = UIColor.mainTextColor()
        cell.textLabel?.text = semesters[indexPath.row]
        cell.selectedBackgroundView = UIView()
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, path) in
            self.deleteSemester(action: action, path: path)
        }
        delete.backgroundColor = UIColor.warning
        
        let edit = UITableViewRowAction(style: .destructive, title: "Edit") { (action, path) in
           self.editSemester(action: action, path: path)
        }
        edit.backgroundColor = UIColor.info
        
        return [delete, edit]
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let moved = semesters[fromIndexPath.row]
        semesters.remove(at: fromIndexPath.row)
        semesters.insert(moved, at: to.row)
    }
    

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
 
    // MARK: - Actions
    
    func editSemester(action: UITableViewRowAction, path: IndexPath) {
        let termEditing = self.semesters[path.row]
        
        // Ask user for new semester name
        let alert = UIAlertController(title: "Change Semester Name", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = termEditing
            textField.borderStyle = .roundedRect
            textField.autocapitalizationType = .words
            textField.attributedText = NSAttributedString(string: "",
                                                          attributes: [.font : UIFont.systemFont(ofSize: 17)])
        }
        
        let save = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text {
                let realm = DatabaseManager.shared.realm
                // Change the semester names for all associated classes
                let classes = realm.objects(Class.self).filter { $0.semester!.term  == termEditing }
                for classObj in classes {
                    DatabaseManager.shared.write {
                        classObj.semester!.term = text
                    }
                }
                self?.semesters[path.row] = text
                self?.tableView.reloadData()
                // Notify that semesters have been updated
                NotificationCenter.default.post(Notification(name: semestersUpdatedNotification))
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(save)
        
        
        self.present(alert, animated: true, completion: nil)

    }
    
    func deleteSemester(action: UITableViewRowAction, path: IndexPath) {
        // At least one semester must be saved
        guard self.semesters.count > 1 else {
            self.presentErrorAlert(title: "Cannot Delete", message: "At least one semester must be stored.")
            self.tableView.setEditing(false, animated: true)
            return
        }
        
        // If no classes associated with this semester, then just delete, no need to warn user
        let realm = DatabaseManager.shared.realm
        let termDeleting = semesters[path.row]
        let classes = realm.objects(Class.self).filter { $0.semester!.term  == termDeleting }
        if classes.count == 0 {
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [path], with: .automatic)
            self.semesters.remove(at: path.row)
            self.tableView.endUpdates()
            return
        }
        
        // Make sure user knows deleting a semester will delete any associated classes
        let title = NSAttributedString(string: "Delete Semester")
        let message = NSAttributedString(string: "Deleting this semester will delete any associated classes, are you sure?",
                                         attributes: [.foregroundColor: UIColor.warning])
        let alert = UIBlurAlertController(size: CGSize(width: 300, height: 200),
                                          title: title,
                                          message: message)
        let cancel = UIButton()
        cancel.backgroundColor = UIColor.info
        cancel.setTitle("Cancel", for: .normal)
        
        let delete = UIButton()
        delete.backgroundColor = UIColor.warning
        delete.setTitle("Delete", for: .normal)
        
        alert.addButton(button: cancel, handler: nil)
        alert.addButton(button: delete, handler: { [weak self] in
            // Get any classes with this semester
            DatabaseManager.shared.write {
                for classObj in classes {
                    DatabaseManager.shared.deleteObjects(classObj.rubrics)
                    DatabaseManager.shared.deleteObjects(classObj.assignments)
                    DatabaseManager.shared.deleteObjects([classObj.semester!, classObj.grade!, classObj])
                }
            }
            
            self?.tableView.beginUpdates()
            self?.tableView.deleteRows(at: [path], with: .automatic)
            self?.semesters.remove(at: path.row)
            self?.tableView.endUpdates()
            
            // Notify that semesters have been updated
            NotificationCenter.default.post(Notification(name: semestersUpdatedNotification))
        })
        
        alert.presentAlert(presentingViewController: self)

    }
    
    @objc func addButtonTouched() {
        // Ask user for name of semester
        let alert = UIAlertController(title: "Add Semester", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Semester name"
            textField.borderStyle = .roundedRect
            textField.autocapitalizationType = .words
            textField.attributedText = NSAttributedString(string: "",
                                                          attributes: [.font : UIFont.systemFont(ofSize: 17)])
        }
        
        let create = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text {
                self?.tableView.beginUpdates()
                self?.tableView.insertRows(at: [IndexPath(row: self?.semesters.count ?? 0, section: 0)],
                                           with: .automatic)
                self?.semesters.append(text)
                self?.tableView.endUpdates()
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(cancel)
        alert.addAction(create)
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                            target: self,
                                            action: #selector(self.addButtonTouched))
            self.navigationItem.leftBarButtonItem = addButton
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
        
        // Save any ordering
        UserDefaults.standard.set(semesters, forKey: UserDefaultKeys.terms.rawValue)
        
        // Notify that semesters have been updated
        NotificationCenter.default.post(Notification(name: semestersUpdatedNotification))
    }


}
