//
//  MigrationManager.swift
//  GradePoint
//
//  Created by Luis Padron on 6/25/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import RealmSwift

final class MigrationManager {
    
    public static func checkMigrations() {
        do {
            let _ = try Realm()
        } catch {
            // Migration needed since failed to open file
            print("Peforming migration.")
            // Peform any migrations
            performMigrations()
        }
    }
    
    private static func performMigrations() {
        let version: UInt64 = 1
        let config = Realm.Configuration(
            schemaVersion: version,
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
            print("Migration complete for version: \(version)")
        } catch {
            fatalError("Error opening Realm after migration: \(error)")
        }
    }
}
