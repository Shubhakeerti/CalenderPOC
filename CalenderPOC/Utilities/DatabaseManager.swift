//
//  DatabaseManager.swift
//  CalenderPOC
//
//  Created by Shubhakeerti on 30/03/18.
//  Copyright © 2018 Shubhakeerti. All rights reserved.
//

import UIKit
import CoreData

public class DatabaseManager {
    
    //MARK: - Swift Singleton initialization
    public static var sharedInstance: DatabaseManager = DatabaseManager()
    
    // MARK: Properties
    static let applicationDocumentsDirectoryName = "com.shub.shubhakeerti.CalenderPOC"
    static let storeFileName = "CalenderPOC.sqlite"
    static let errorDomain = "DatabaseManager"
    
    // The managed object model
    static let managedObjectModel: NSManagedObjectModel = { () -> NSManagedObjectModel in
        let modelURL = Bundle.main.url(forResource: "CalenderPOC", withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()
    
    var persistentStoreCoordinator: NSPersistentStoreCoordinator
    init() {
        // This implementation creates and return a coordinator, having added the store for the application to it.
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: DatabaseManager.managedObjectModel)
        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true, /* Key to automatically attempt to migrate versioned stores. */
                NSInferMappingModelAutomaticallyOption: true /* Key to attempt to create the mapping model automatically. */
            ]
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: DatabaseManager.storeURL, options: options)
        } catch {
            fatalError("Could not add the persistent store: \(error).")
        }
        self.persistentStoreCoordinator = persistentStoreCoordinator
    }
    
    /// The directory the application uses to store the Core Data store file.
    static let applicationDocumentsDirectory: URL = { () -> URL in
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.cocoacasts.PersistentStores" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    /// URL for the main Core Data store file.
    static let storeURL: URL = {
        return DatabaseManager.applicationDocumentsDirectory.appendingPathComponent(storeFileName)
    }()
    
    // The context that has the direct access to persistent store coordinator
    public lazy var parentContext: NSManagedObjectContext = { () -> NSManagedObjectContext in
        let parentContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        parentContext.persistentStoreCoordinator = DatabaseManager.sharedInstance.persistentStoreCoordinator
        parentContext.undoManager = nil
        parentContext.retainsRegisteredObjects = true
        return parentContext
    }()
    
    // The context which can be used by UI. However utilizing this context will block the caller thread.
    public lazy var mainContext: NSManagedObjectContext = { () -> NSManagedObjectContext in
        let mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.parent = self.parentContext
        mainContext.undoManager = nil
        mainContext.retainsRegisteredObjects = true
        return mainContext
    }()
    
    // The context which can be used by any thread. Utilizing this context will not block the caller thread.
    public lazy var childContext: NSManagedObjectContext = { () -> NSManagedObjectContext in
        let childContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        childContext.parent = self.mainContext
        childContext.undoManager = nil
        childContext.retainsRegisteredObjects = true
        return childContext
    }()
    
    // for saving syncronously
    func saveContextSynchronously(_ managedObjectContext: NSManagedObjectContext, completionBlock: ((Bool) -> Void)? = nil) {
        managedObjectContext.performAndWait({ () -> Void in
            if managedObjectContext.hasChanges {
                do {
                    try managedObjectContext.save()
                    
                    // Check whether present context has associated with the parent context
                    if managedObjectContext.parent != nil {
                        // Do recursive call back
                        self.saveContextSynchronously(managedObjectContext.parent!, completionBlock: completionBlock)
                    } else {
                        completionBlock?(true)
                    }
                } catch _ as NSError {
                    // Oops, something went wrong.
                    completionBlock?(false)
                }
            } else {
                completionBlock?(true)
            }
        })
    }
    
    // for saving asyncronously
    func saveContext(_ managedObjectContext: NSManagedObjectContext, completionBlock: ((Bool) -> Void)? = nil) {
        
        if managedObjectContext.hasChanges {
            managedObjectContext.perform { () -> Void in
                do {
                    try managedObjectContext.save()
                    if managedObjectContext.parent != nil {
                        self.saveContext(managedObjectContext.parent!, completionBlock: completionBlock)
                    } else {
                        completionBlock?(true)
                    }
                } catch _ as NSError {
                    // Oops, something went wrong.
                    completionBlock?(false)
                }
            }
        } else {
            completionBlock?(true)
        }
    }
    
    // Clean
    deinit {
        // Returns all the contexts to its base state
        self.childContext.reset()
        self.parentContext.reset()
        self.mainContext.reset()
        
        var array: [String] = [String]()
        if let persistentStoreURL = DatabaseManager.sharedInstance.persistentStoreCoordinator.persistentStores.last?.url?.path {
            array.append(persistentStoreURL)
        }
    }
    
    //MARK:
    
    func deleteObjects(_ objects: [NSManagedObject], context: NSManagedObjectContext, save: Bool = true) {
        // Get context based on parameter
        for eachObject in objects {
            if eachObject.managedObjectContext == context {
                context.delete(eachObject)
            }
        }
        if save {
            saveContext(context, completionBlock: nil)
        }
    }
}
