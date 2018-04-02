//
//  CalendarEvent.swift
//  CalenderPOC
//
//  Created by Shubhakeerti on 30/03/18.
//  Copyright © 2018 Shubhakeerti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(CalendarEvent)
public class CalendarEvent: NSManagedObject {

}

extension CalendarEvent: ManagedObjectProtocol {
    public static var managedEntityName: String { return "CalendarEvent" }

    static func saveEvent(event: EventDataSetup, completion:(() -> ())? = nil) {
        let _ = self.getEvent(event: event, in: DatabaseManager.sharedInstance.childContext)
        DatabaseManager.sharedInstance.saveContextSynchronously(DatabaseManager.sharedInstance.childContext) { (success) in
            completion?()
        }
    }
    
    static func getEvent(event: EventDataSetup, in context: NSManagedObjectContext) -> CalendarEvent? {
        let predicate: NSPredicate = NSPredicate(format: "eventId == %@", event.eventId as NSDate)
        if let coreDataEvent = self.getUniqueObject(predicate, inMangedObjectContext: context) as? CalendarEvent {
            self.addEvent(event: event, in: coreDataEvent)
            return coreDataEvent
        }
        return nil
    }
    
    static func addEvent(event: EventDataSetup, in coreDataEvent: CalendarEvent) {
        coreDataEvent.eventId = event.eventId as NSDate
        coreDataEvent.title = event.title
        coreDataEvent.startDate = event.startDate.date as NSDate
        coreDataEvent.endDate = event.enddate.date as NSDate
        coreDataEvent.isAllDay = event.isAllDay
    }
    
    public static func getAllEvents() -> [CalendarEvent] {
        let sortDescription: NSSortDescriptor = NSSortDescriptor(key: "eventId", ascending: true)
        if let events = self.all(withPredicate: nil, sortDescription: [sortDescription], mangedObjectContext: DatabaseManager.sharedInstance.mainContext) as? [CalendarEvent] {
            return events
        }
        return []
    }
}
