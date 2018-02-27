//
//  DatabaseManager.swift
//  GradePoint
//
//  Created by Luis Padron on 6/25/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import Foundation
import RealmSwift

/// The Realm manager for Realm
final class DatabaseManager {
    
    public static let shared: DatabaseManager = DatabaseManager()

    public static let fileName: String = "gradepoint-db.realm"

    private static var hasSetup: Bool = false

    // MARK: Realm Methods/Helpers
    
    /// The Realm instance to be used throughout the application
    public lazy var realm: Realm = {
        guard DatabaseManager.hasSetup else {
            fatalError("Realm has not been setup before accessing realm.\nMake sure to call DatabaseManager.setupRealm.")
        }

        return try! Realm()
    }()

    /// Handles writing to Realm safely
    public func write(_ block: () -> Void) {
        guard !realm.isInWriteTransaction else {
            // Perform write without calling write again
            block()
            return
        }

        // Open new write transaction
        do {
            try realm.write {
                block()
            }
        } catch {
            print("ERROR writing to Realm.\n\(error)")
        }
    }
    
    /// Deletes sent in objects from Realm List if possible
    public func deleteObjects<T: Object>(_ objects: List<T>) {
        guard !objects.isInvalidated else {
            print("ERROR: Canno't delete objects from Realm, they have been invalidated.")
            return
        }

        self.write {
            // Delete only objects that are valid, if invalidated, something went wrong and object has already been deleted.
            let validObjects = objects.filter { !$0.isInvalidated }
            validObjects.forEach { realm.delete($0) }
        }
    }
    
    /// Deletes sent in objects from Realm Results if possible
    public func deleteObjects<T: Object>(_ objects: Results<T>) {
        guard !objects.isInvalidated else {
            print("ERROR: Canno't delete objects from Realm, they have been invalidated.")
            return
        }
        
        self.write {
            // Delete only objects that are valid, if invalidated, something went wrong and object has already been deleted.
            let validObjects = objects.filter { !$0.isInvalidated }
            validObjects.forEach { realm.delete($0) }
        }
    }
    
    /// Deletes sent in objects from Realm if possible
    public func deleteObjects(_ objects: [Object]) {
        self.write {
            // Delete only objects that are valid, if invalidated, something went wrong and object has already been deleted.
            let validObjects = objects.filter { !$0.isInvalidated }
            validObjects.forEach { realm.delete($0) }
        }
    }
    
    /// Adds a new object into Realm
    public func addObject(_ object: Object) {
        self.write {
            realm.add(object)
        }
    }
    
    /// Creates a new object into realm
    public func createObject<T: Object>(_ type: T.Type, value: Any, update: Bool) {
        self.write {
            realm.create(type, value: value, update: update)
        }
    }

    /// The current schema version of the Realm file, this is not the version of the actual Realm file on the device
    /// but instead what the version should be, this version number should be changed whenever the schema is updated.
    // And any migration code should be added in `performMigration`
    public static var currentSchemaVersion: UInt64 = 3

    // MARK: Realm Setup

    public static func setupRealm(completion: (() -> Void)? = nil) {
        // First move the Realm file if needed, this is done on application versions < 2.0
        moveRealmIfNeeded()

        let directory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: kGradePointGroupId)!
        let path: URL = directory.appendingPathComponent(fileName, isDirectory: true)
        let config = Realm.Configuration(fileURL: path,
                                         schemaVersion: currentSchemaVersion,
                                         migrationBlock: performMigration)

        // Update default config
        Realm.Configuration.defaultConfiguration = config

        // Try to open realm again
        do {
            let _ = try Realm()
            print("Migration complete for version: \(currentSchemaVersion)")
        } catch {
            fatalError("Error opening Realm after migration: \(error)")
        }

        hasSetup = true

        // Call completion
        completion?()
    }
    
    // MARK: Migration

    /// Moves the Realm file to the new location, only required on application versions < 2.0
    private static func moveRealmIfNeeded() {
        let fm = FileManager.default
        guard let origPath = Realm.Configuration.defaultConfiguration.fileURL else {
            print("Unable to get original path...")
            return
        }

        // Create new realm path
        let groupPath = fm.containerURL(forSecurityApplicationGroupIdentifier: kGradePointGroupId)!
        let newPath = groupPath.appendingPathComponent(fileName, isDirectory: true)

        if (fm.fileExists(atPath: origPath.path) && !fm.fileExists(atPath: newPath.path)) {
            do {
                try fm.moveItem(atPath: origPath.path, toPath: newPath.path)
            } catch {
                print("Error moving Realm file: \(error)")
            }
        }
    }

    /// Peforms any required Realm migrations
    private static func performMigration(migration: Migration, version: UInt64) {
        // Add new isFavorite property, rename rubric property of Assignment class
        if version < 1 {
            migration.enumerateObjects(ofType: Class.className()) { _, newObj in
                newObj!["isFavorite"] = false
            }
            migration.renameProperty(onType: Assignment.className(), from: "associatedRubric", to: "rubric")
        }
        // Convert credit hours from integer to double
        if version < 2 {
            migration.enumerateObjects(ofType: Class.className(), {oldObj, newObj  in
                newObj!["creditHours"] = Double(oldObj!["creditHours"] as! Int)
            })
        }
        // Add new ClassGradeType field
        if version < 3 {
            migration.enumerateObjects(ofType: Class.className(), {oldObj, newObj in
                let type = (oldObj!["rubrics"] as! List<DynamicObject>).count > 0 ? ClassGradeType.weighted : ClassGradeType.previous
                newObj!["classGradeType"] = type.rawValue
            })
        }
    }

}
