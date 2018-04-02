//
//  EventAddEditViewController.swift
//  CalenderPOC
//
//  Created by Shubhakeerti on 28/03/18.
//  Copyright © 2018 Shubhakeerti. All rights reserved.
//

import UIKit

struct EventDataSetup {
    var title: String
    var startDate: ComputedDate
    var enddate: ComputedDate
    var isAllDay: Bool
    var eventId: Date
    init(title: String, startDate: ComputedDate, enddate: ComputedDate, isAllDay: Bool, eventId: Date) {
        self.title = title
        self.startDate = startDate
        self.enddate = enddate
        self.isAllDay = isAllDay
        self.eventId = eventId
    }
}

class EventAddEditViewController: UITableViewController {
    var isAllDay: Bool = false
    var isNewEvent: Bool = true
    lazy var selectedDate: ComputedDate = {
       return ComputedDate(date: Date())
    }()

    lazy var eventData: EventDataSetup = {
        return EventDataSetup(title: "", startDate: self.startDate, enddate: self.endDate, isAllDay: self.isAllDay, eventId: Date())
    }()

    private lazy var startDate: ComputedDate = {
        var currentDateComponent: DateComponents = CalenderManager.sharedmanager.getDateComponentsWithTime(date: Date())
        var startDateComponent: DateComponents = CalenderManager.sharedmanager.getDateComponentsWithTime(date: self.selectedDate.date)
        startDateComponent.hour = currentDateComponent.hour
        startDateComponent.minute = 0
        startDateComponent.second = 0
        return ComputedDate(date: CalenderManager.sharedmanager.calendar.date(from: startDateComponent)!)
    }()
    
    private lazy var endDate: ComputedDate = {
        var startDateComponent: DateComponents = CalenderManager.sharedmanager.getDateComponentsWithTime(date: self.startDate.date)
        startDateComponent.hour = startDateComponent.hour! + 1
        if self.isAllDay {
            startDateComponent.day = startDateComponent.day! + 1
        }
        return ComputedDate(date: CalenderManager.sharedmanager.calendar.date(from: startDateComponent)!)

    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.isNewEvent ? "New Event" : "Edit Event"
        self.registerCells()
        self.updateEventData(true)
    }
    
    func updateEventData(_ reload: Bool) {
        self.eventData = EventDataSetup(title: "", startDate: self.startDate, enddate: self.endDate, isAllDay: self.isAllDay,eventId: self.eventData.eventId)
        if reload {
            self.tableView.reloadData()
        }
    }

    func registerCells() {
        self.tableView.register(UINib(nibName: "EventTitleCell", bundle: nil), forCellReuseIdentifier: "EventTitleCell")
        self.tableView.register(UINib(nibName: "DateTimeCell", bundle: nil), forCellReuseIdentifier: "DateTimeCell")
    }
    
    func showDateSelector(selectionType: SelectionType) {
        let dateTimeSelectorNav: UINavigationController = StoryboardHelper.dateTimeSelectionViewController() as! UINavigationController
        let dateTimeSelector: DateTimeSelectionController = dateTimeSelectorNav.viewControllers[0] as! DateTimeSelectionController
        dateTimeSelector.selectionType = selectionType
        dateTimeSelector.startDate = self.eventData.startDate
        dateTimeSelector.endDate = self.eventData.enddate
        dateTimeSelector.delegate = self
        self.present(dateTimeSelectorNav, animated: true, completion: nil)

    }
    
    @IBAction func closeButtonAction(_ sender: UIBarButtonItem) {
        let actionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Discard changes", style: UIAlertActionStyle.destructive, handler: { (_) in
            self.dismiss(animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func doneButtonAction(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        CalendarEvent.saveEvent(event: self.eventData) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell: EventTitleCell = tableView.dequeueReusableCell(withIdentifier: "EventTitleCell", for: indexPath) as! EventTitleCell
            cell.configureCell(title: self.eventData.title, completion: { [weak self] (eventTitle) in
                self?.eventData.title = eventTitle
            })
            return cell
            
        case 1:
            let cell: DateTimeCell = tableView.dequeueReusableCell(withIdentifier: "DateTimeCell", for: indexPath) as! DateTimeCell
            cell.configureCell(dataSetup: DateTimeCelldataSetup(startDate: self.eventData.startDate, endDate: self.eventData.enddate, isAllDay: self.eventData.isAllDay), completionBlock: { [weak self] (selectionType, isAllDay) in
                self?.isAllDay = isAllDay
                self?.eventData.isAllDay = isAllDay
                if let selectionTypeUW = selectionType {
                    self?.showDateSelector(selectionType: selectionTypeUW)
                }
            })
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

extension EventAddEditViewController: DateSelectorProtocol {
    func didSelectDate(selectedDate: ComputedDate, selectionType: SelectionType) {
        if selectionType == .StartDate {
            self.startDate = selectedDate
        } else {
            self.endDate = selectedDate
        }
        self.updateEventData(true)
    }
    
    func didSelectRange(startDate: ComputedDate, endDate: ComputedDate) {
        self.startDate = startDate
        self.endDate = endDate
        self.updateEventData(true)
    }
}
