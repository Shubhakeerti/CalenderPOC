//
//  CalenderManager.swift
//  CalenderPOC
//
//  Created by Shubhakeerti on 20/03/18.
//  Copyright © 2018 Shubhakeerti. All rights reserved.
//

import UIKit

class CalenderManager {
    
    private let yearComponent = Calendar.Component.year
    private let monthComponent = Calendar.Component.month
    private let weekComponent = Calendar.Component.weekOfMonth
    private let weekdayComponent = Calendar.Component.weekday
    private let dayComponent = Calendar.Component.day
    private let hourComponent = Calendar.Component.hour
    private let minuteComponent = Calendar.Component.minute
    private let secondsComponent = Calendar.Component.second

    static var sharedmanager: CalenderManager = CalenderManager()
    
    lazy var calendar: Calendar = {
        var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.firstWeekday = 1 //sunday
        return calendar
    }()
    
    lazy var fullMonthNameDateFormat: DateFormatter = {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM" //March
        return dateFormatter
    }()
    
    lazy var fullMonthWithYearDateFormat: DateFormatter = {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy" // March 2018
        return dateFormatter
    }()
    
    lazy var timeFormat: DateFormatter = {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" // 10:45 AM
        return dateFormatter
    }()
    
    func getDateComponents(date: Date) -> DateComponents {
        return self.calendar.dateComponents([yearComponent, monthComponent, weekComponent, weekdayComponent, dayComponent], from: date)
    }
    func getDateComponentsWithTime(date: Date) -> DateComponents {
        return self.calendar.dateComponents([yearComponent, monthComponent, weekComponent, weekdayComponent, dayComponent, hourComponent, minuteComponent, secondsComponent], from: date)
    }
}

// Custom Date component
struct ComputedDate {
    var date : Date {
        didSet {
            onlyDateComponent = nil
            dateTimeComponent = nil
        }
    }
    var onlyDateComponent: DateComponents?
    var dateTimeComponent: DateComponents?

    init(date : Date) {
        self.date = date
    }
    
    mutating func getDateComponent() -> DateComponents {
        if let onlyDateComponentUW = onlyDateComponent {
            return onlyDateComponentUW
        } else {
            onlyDateComponent = CalenderManager.sharedmanager.getDateComponents(date: self.date)
            return onlyDateComponent!
        }
    }
    
    mutating func getDateComponentWithTime() -> DateComponents {
        if let dateTimeComponentUW = dateTimeComponent {
            return dateTimeComponentUW
        } else {
            dateTimeComponent = CalenderManager.sharedmanager.getDateComponentsWithTime(date: self.date)
            return dateTimeComponent!
        }
    }
}
