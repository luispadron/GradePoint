//
//  DatabaseManager.swift
//  GradePoint
//
//  Created by Luis Padron on 6/25/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import RealmSwift

/// The Realm manager for Realm
final class DatabaseManager {
    
    public static let shared: DatabaseManager = DatabaseManager()
    
    // MARK: Realm Methods/Helpers
    
    /// The Realm instance to be used throughout the application
    public lazy var realm: Realm = {
        return try! Realm()
    }()
    
    /// Deletes sent in objects from Realm List if possible
    public func deleteObjects<T>(_ objects: List<T>) {
        guard !objects.isInvalidated else {
            print("ERROR: Canno't delete objects from Realm, they have been invalidated.")
            return
        }
        
        do {
            try realm.write {
                // Delete only objects that are valid, if invalidated, something went wrong and object has already been deleted.
                let validObjects = objects.filter { !$0.isInvalidated }
                validObjects.forEach { realm.delete($0) }
            }
        } catch {
            print("ERROR: Unable to delete Realm object from database.\n\(error)")
        }
    }
    
    /// Deletes sent in objects from Realm Results if possible
    public func deleteObjects<T>(_ objects: Results<T>) {
        guard !objects.isInvalidated else {
            print("ERROR: Canno't delete objects from Realm, they have been invalidated.")
            return
        }
        
        do {
            try realm.write {
                // Delete only objects that are valid, if invalidated, something went wrong and object has already been deleted.
                let validObjects = objects.filter { !$0.isInvalidated }
                validObjects.forEach { realm.delete($0) }
            }
        } catch {
            print("ERROR: Unable to delete Realm object from database.\n\(error)")
        }
    }
    
    /// Deletes sent in objects from Realm if possible
    public func deleteObjects(_ objects: [Object]) {
        do {
            try realm.write {
                // Delete only objects that are valid, if invalidated, something went wrong and object has already been deleted.
                let validObjects = objects.filter { !$0.isInvalidated }
                validObjects.forEach { realm.delete($0) }
            }
        } catch {
            print("ERROR: Unable to delete Realm object from database.\n\(error)")
        }
    }
    
    /// Adds a new object into Realm
    public func addObject(_ object: Object) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print("ERROR: Unable to add Realm object.\n\(error)")
        }
    }
    
    /// Creates a new object into realm
    public func createObject<T: Object>(_ type: T.Type, value: Any, update: Bool) {
        do {
            try realm.write {
                realm.create(type, value: value, update: update)
            }
        } catch {
            print("ERROR: Unable to create Realm object.\n\(error)")
        }
    }
    
    // MARK: Migration
    
    /// The current schema version of the Realm file, this is not the version of the actual Realm file on the device
    /// but instead what the version should be, this version number should be changed whenever the schema is updated.
    // And any migration code should be added in `performMigration`
    public static var currentSchemaVersion: UInt64 = 1
    
    /// Performs migration and updates any old schemas to `currentSchemaVersion`
    public static func performMigrations(completion: (() -> Void)? = nil) {
        let config = Realm.Configuration(
            schemaVersion: currentSchemaVersion,
            migrationBlock: { migration, oldVersion in
                if (oldVersion < 1) {
                    migration.enumerateObjects(ofType: Class.className()) { _, newObj in
                        newObj!["isFavorite"] = false
                    }
                }
            }
        )
        // Set config
        Realm.Configuration.defaultConfiguration = config
        // Try to open realm again
        do {
            let _ = try Realm()
            print("Migration complete for version: \(currentSchemaVersion)")
        } catch {
            fatalError("Error opening Realm after migration: \(error)")
        }
        
        // Call completion
        completion?()
    }
}
