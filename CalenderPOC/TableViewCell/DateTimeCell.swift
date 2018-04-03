//
//  DateTimeCell.swift
//  CalenderPOC
//
//  Created by Shubhakeerti on 29/03/18.
//  Copyright © 2018 Shubhakeerti. All rights reserved.
//

import UIKit

struct DateTimeCelldataSetup {
    var startDate: ComputedDate
    var endDate: ComputedDate
    var isAllDay: Bool
    init(startDate: ComputedDate, endDate: ComputedDate, isAllDay: Bool = true) {
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
    }
}

enum SelectionType {
    case Date
    case StartDate
    case EndDate
    case Time
}

class DateTimeCell: UITableViewCell {

    @IBOutlet weak var startTitleLabel: UILabel!
    @IBOutlet weak var endTitleLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var startDurationLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var endDurationLabel: UILabel!
    @IBOutlet weak var allDaySwitch: UISwitch!
    
    private var returnCallback: ((SelectionType?, Bool) -> Void)?
    
    private lazy var persistanceDataSetup: DateTimeCelldataSetup = {
        var startDateComponent: DateComponents = CalenderManager.sharedmanager.getDateComponentsWithTime(date: Date())
        startDateComponent.hour = 0
        startDateComponent.minute = 0
        startDateComponent.second = 0
       let dataSetup = DateTimeCelldataSetup(startDate: ComputedDate(date: CalenderManager.sharedmanager.calendar.date(from: startDateComponent)!), endDate: ComputedDate(date: CalenderManager.sharedmanager.calendar.date(byAdding: .day, value: 1, to: CalenderManager.sharedmanager.calendar.date(from: startDateComponent)!)!), isAllDay: true)
        return dataSetup
    }()
    
    lazy var dateFormatter: DateFormatter = {
        let dateformatter: DateFormatter = DateFormatter()
        dateformatter.dateFormat = "EEE, d MMM yyyy"
        return dateformatter
    }()
    
    lazy var timeFormatter: DateFormatter = {
        let timeFormatter: DateFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        return timeFormatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK:- Action Methods
    @IBAction func allDaySwitchAction(_ sender: UISwitch) {
        self.persistanceDataSetup.isAllDay = sender.isOn
        if self.persistanceDataSetup.isAllDay {
            var currentDateComponent: DateComponents = CalenderManager.sharedmanager.getDateComponentsWithTime(date: Date())
            var startDateComponent: DateComponents = CalenderManager.sharedmanager.getDateComponentsWithTime(date: self.persistanceDataSetup.startDate.date)
            startDateComponent.hour = currentDateComponent.hour
            startDateComponent.minute = 0
            startDateComponent.second = 0
            self.persistanceDataSetup.startDate = ComputedDate(date: CalenderManager.sharedmanager.calendar.date(from: startDateComponent)!)
            self.persistanceDataSetup.endDate = ComputedDate(date: CalenderManager.sharedmanager.calendar.date(byAdding: .day, value: 1, to: self.persistanceDataSetup.startDate.date)!)

        } else {
            self.persistanceDataSetup.endDate = ComputedDate(date: CalenderManager.sharedmanager.calendar.date(byAdding: .hour, value: 1, to: self.persistanceDataSetup.startDate.date)!)
        }
        self.configureCell(dataSetup: self.persistanceDataSetup, completionBlock: self.returnCallback)
        self.returnCallback?(nil, self.persistanceDataSetup.isAllDay)
    }
    
    @IBAction func startDateAction(_ sender: UIButton) {
        self.returnCallback?(.StartDate, self.persistanceDataSetup.isAllDay)
    }
    
    @IBAction func endDateAction(_ sender: UIButton) {
        if self.persistanceDataSetup.isAllDay {
            self.returnCallback?(.EndDate, self.persistanceDataSetup.isAllDay)
        } else {
            self.returnCallback?(.Time, self.persistanceDataSetup.isAllDay)
        }
    }
    
    //MARK:- UI Configuration Methods
    func configureCell(dataSetup: DateTimeCelldataSetup, completionBlock: ((SelectionType?, Bool) -> Void)?) {
        self.persistanceDataSetup = dataSetup
        self.returnCallback = completionBlock
        self.startDateLabel.text = self.getOnlyDateString(date: dataSetup.startDate)
        self.startDurationLabel.text = "in " + self.getStartDuration(startdate: ComputedDate(date: Date()), endDate: dataSetup.startDate)
        self.endDurationLabel.text = self.getTimeDuration(startdate: dataSetup.startDate, endDate: dataSetup.endDate)
        if dataSetup.isAllDay {
            startTitleLabel.text = "Start"
            endTitleLabel.text = "End"
            self.allDaySwitch.isOn = true
            self.endDateLabel.text = self.getOnlyDateString(date: dataSetup.endDate)
        } else {
            startTitleLabel.text = "Date"
            endTitleLabel.text = "Time"
            self.allDaySwitch.isOn = false
            self.endDateLabel.text = self.getTimeRangeString(startDate: dataSetup.startDate, endDate: dataSetup.endDate)
        }
    }
    
    private func getOnlyDateString(date: ComputedDate) -> String {
        return self.dateFormatter.string(from: date.date)
    }
    
    private func getTimeRangeString(startDate: ComputedDate, endDate: ComputedDate) -> String {
        return self.timeFormatter.string(from: startDate.date) + " \u{2192} " + self.timeFormatter.string(from: endDate.date)
    }
    
    private func getStartDuration(startdate: ComputedDate, endDate: ComputedDate) -> String {
        let currentDateComponent: DateComponents = CalenderManager.sharedmanager.getDateComponents(date: startdate.date)
        let startDateComponent: DateComponents = CalenderManager.sharedmanager.getDateComponents(date: endDate.date)
        if currentDateComponent.year! < startDateComponent.year! {
            let difference: Int = startDateComponent.year! - currentDateComponent.year!
            return "\(difference)" + (difference > 1 ? " years" : " year")
        }
        else if currentDateComponent.month! < startDateComponent.month! {
            let difference: Int = startDateComponent.month! - currentDateComponent.month!
            return "\(difference)" + (difference > 1 ? " months" : " month")
        }
        else if currentDateComponent.day! < startDateComponent.day! {
            let difference: Int = startDateComponent.day! - currentDateComponent.day!
            if difference > 7 {
                let weeks: Int = Int(difference / 7)
                return "\(weeks)" + (weeks > 1 ? " weeks": " week")
            } else if difference == 1 {
                return "Tomorrow"
            } else {
                return "\(difference)" + (difference > 1 ? " days" : " day")
            }
        }
        return "Today"
    }
    
    private func getTimeDuration(startdate: ComputedDate, endDate: ComputedDate) -> String {
        var returnString : String = "Duration: "
        if self.allDaySwitch.isOn {
            let dayDifferenceString = self.getStartDuration(startdate: startdate, endDate: endDate)
            if dayDifferenceString == "Today" {
                returnString = returnString + "1 day"
            } else if dayDifferenceString == "Tomorrow" {
                returnString = returnString + "2 days"
            } else {
                returnString = returnString + dayDifferenceString
            }
        } else {
            let startDateComponent: DateComponents = CalenderManager.sharedmanager.getDateComponentsWithTime(date: startdate.date)
            let endDateComponent: DateComponents = CalenderManager.sharedmanager.getDateComponentsWithTime(date: endDate.date)
            if startDateComponent.hour! < endDateComponent.hour! {
                let difference: Int = endDateComponent.hour! - startDateComponent.hour!
                returnString = returnString + "\(difference)" + (difference > 1 ? " hours" : " hour")
            } else {
                let difference: Int = endDateComponent.minute! - startDateComponent.minute!
                returnString = returnString + "\(difference)" + (difference > 1 ? " minutes" : " minute")
            }
        }
        return returnString
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
