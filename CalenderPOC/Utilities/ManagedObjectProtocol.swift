//
//  ManagedObjectProtocol.swift
//  CalenderPOC
//
//  Created by Shubhakeerti on 30/03/18.
//  Copyright © 2018 Shubhakeerti. All rights reserved.
//

import UIKit
import CoreData

public protocol ManagedObjectProtocol {
static var managedEntityName: String { get }
}

// a protocol extention which confirms to NSManagedObject and implements extra Utility methods needed for fetching any entity
public extension ManagedObjectProtocol where Self: NSManagedObject {

    //To get all the objects of an entity with optional predicate or sortDescriptions
    static func all(withPredicate predicate: NSPredicate? = nil, sortDescription: [NSSortDescriptor]? = nil, mangedObjectContext moc: NSManagedObjectContext) -> [AnyObject]? {
        let request = NSFetchRequest<NSManagedObject>(entityName: managedEntityName)
        request.predicate = predicate
        if let sortDescriptiorUW = sortDescription {
            request.sortDescriptors = sortDescriptiorUW
        }
        do {
            let result = try moc.fetch(request)
            return result
        } catch {
            return nil
        }
    }

    static func findUniqueObject(_ predicate: NSPredicate, inMangedObjectContext moc: NSManagedObjectContext) -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: managedEntityName)
        request.predicate = predicate
        var object: NSManagedObject? = nil
        
        do {
            let fetchedObjects = try moc.fetch(request)
            object = fetchedObjects.first
        } catch {
            
        }
        
        return object
    }

    // either finds or create a new one a returns ManagedObject
    static func getUniqueObject(_ predicate: NSPredicate, inMangedObjectContext moc: NSManagedObjectContext) -> NSManagedObject {
        return findUniqueObject(predicate, inMangedObjectContext: moc) ?? self.insert(moc)!
    }

    
    static func getCount(WithPredicate predicate: NSPredicate? = nil, inMangedObjectContext moc: NSManagedObjectContext = DatabaseManager.sharedInstance.mainContext) -> Int {
        let request = NSFetchRequest<NSNumber>(entityName: managedEntityName)
        request.predicate = predicate
        let count: Int
        do {
            count = try moc.count(for: request)
        } catch _ as NSError {
            count = 0
        }
        return count
    }

    static func entityDescription(_ moc: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: managedEntityName, in: moc)
    }

    static func insert(_ moc: NSManagedObjectContext) -> NSManagedObject? {
        let object = NSEntityDescription.insertNewObject(forEntityName: managedEntityName, into: moc)
        return object
    }

    static func delete(_ predicate: NSPredicate, inMangedObjectContext moc: NSManagedObjectContext) {
        if let object = findUniqueObject(predicate, inMangedObjectContext: moc) {
            moc.delete(object)
        }
    }

    static func deleteAll(inManagedObjectContext moc: NSManagedObjectContext) {
        if let allObjects = self.all(mangedObjectContext: DatabaseManager.sharedInstance.childContext) as? [NSManagedObject] {
            for objects in allObjects {
                moc.delete(objects)
            }
        }
    }
}

