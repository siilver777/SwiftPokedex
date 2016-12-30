//
//  DataManager.swift
//  PokeStats
//
//  Created by Jason Pierna on 17/12/2016.
//  Copyright © 2016 Jason Pierna. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    public static let shared = DataManager()
    public var context: NSManagedObjectContext?
    
    private init() {
        if let modelURL = Bundle.main.url(forResource: "PokeStats", withExtension: "momd") {
            if let model = NSManagedObjectModel(contentsOf: modelURL) {
                if let storageURL = FileManager.docummentsURL(childPath: "PokeStats.db") {
                    
                    let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
                    _ = try? storeCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storageURL, options: nil)
                    
                    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    context.persistentStoreCoordinator = storeCoordinator
                    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                    self.context = context
                }
            }
        }
    }
}
