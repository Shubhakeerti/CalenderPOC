//
//  CalendarEvent+CoreDataProperties.swift
//  CalenderPOC
//
//  Created by Shubhakeerti on 30/03/18.
//  Copyright © 2018 Shubhakeerti. All rights reserved.
//
//

import Foundation
import CoreData


extension CalendarEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CalendarEvent> {
        return NSFetchRequest<CalendarEvent>(entityName: "CalendarEvent")
    }

    @NSManaged public var eventId: NSDate?
    @NSManaged public var isAllDay: Bool
    @NSManaged public var startDate: NSDate?
    @NSManaged public var endDate: NSDate?
    @NSManaged public var title: String?

}
