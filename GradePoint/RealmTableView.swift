//
//  RealmTableView.swift
//  GradePoint
//
//  Created by Luis Padron on 9/8/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift
import LPSnackbar

protocol RealmTableView: class {
    associatedtype RealmObject: Equatable

    var realmData: [[RealmObject]] { get set }

    func addObject(_ object: RealmObject, section: Int)

    func deleteObject(_ object: RealmObject, section: Int, allowsUndo: Bool, completion: ((Bool, RealmObject) -> Void)?)

    func moveObject(_ object: RealmObject, from old: IndexPath, to new: IndexPath)

    func reloadObject(_ object: RealmObject, section: Int)
}

extension RealmTableView where Self: UITableViewController {
    func addObject(_ object: RealmObject, section: Int) {
        tableView.beginUpdates()
        realmData[section].append(object)
        tableView.insertRows(at: [IndexPath(row: realmData[section].count - 1, section: section)], with: .automatic)
        if realmData[section].count == 1 {
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
        tableView.endUpdates()
    }

    func deleteObject(_ object: RealmObject, section: Int, allowsUndo: Bool, completion: ((Bool, RealmObject) -> Void)?) {
        let row = realmData[section].index(of: object)!
        tableView.beginUpdates()
        realmData[section].remove(at: row)
        tableView.deleteRows(at: [IndexPath(row: row, section: section)], with: .left)
        if realmData[section].count == 0 {
            tableView.reloadSections(IndexSet(integer: section), with: .automatic)
        }
        tableView.endUpdates()

        guard allowsUndo else { return }

        let snack = LPSnackbar(title: "Class deleted.", buttonTitle: "UNDO", displayDuration: 4.0)
        snack.viewToDisplayIn = navigationController?.view
        snack.bottomSpacing = (tabBarController?.tabBar.frame.height ?? 0) + 12

        snack.show() { undone in
            if undone {
                self.tableView.beginUpdates()
                self.realmData[section].append(object)
                self.tableView.insertRows(at: [IndexPath(row: self.realmData[section].count - 1, section: section)], with: .automatic)
                if self.realmData[section].count - 1  == 0  {
                    self.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
                }
                self.tableView.endUpdates()
            }

            completion?(undone, object)
        }
    }

    func moveObject(_ object: RealmObject, from old: IndexPath, to new: IndexPath) {
        tableView.beginUpdates()
        realmData[old.section].remove(at: old.row)
        realmData[new.section].append(object)
        tableView.deleteRows(at: [old], with: .automatic)
        if realmData[old.section].count == 0 {
            tableView.reloadSections(IndexSet(integer: old.section), with: .automatic)
        }
        tableView.insertRows(at: [new], with: .automatic)
        if realmData[new.section].count - 1 == 0 {
            tableView.reloadSections(IndexSet(integer: new.section), with: .automatic)
        }
        tableView.endUpdates()
    }

    func reloadObject(_ object: RealmObject, section: Int) {
        let row = realmData[section].index(of: object)!
        tableView.beginUpdates()
        tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .automatic)
        tableView.endUpdates()
    }
}
