//
//  MigrationManager.swift
//  GradePoint
//
//  Created by Luis Padron on 6/25/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import RealmSwift

/// Class helper to handle Realm configurations and migrations
final class MigrationManager {
    
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
