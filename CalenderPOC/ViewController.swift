//
//  ViewController.swift
//  CalenderPOC
//
//  Created by Shubhakeerti on 19/03/18.
//  Copyright © 2018 Shubhakeerti. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var weekDayCollectionView: UICollectionView!
    @IBOutlet weak var monthCollectionView: UICollectionView!
    @IBOutlet weak var agendaTableView: UITableView!
    
    @IBOutlet weak var collapsedAspectRatio: NSLayoutConstraint!
    @IBOutlet weak var expandedAspectRatio: NSLayoutConstraint!
    fileprivate var currentDate: ComputedDate = ComputedDate(date: Date())
    fileprivate var selecteddate: ComputedDate = ComputedDate(date: Date())
    
    fileprivate var weekDayArray: Array = [WeekdayDataSetup]()
    
    fileprivate var savedEvents: Dictionary = [String: [CalendarEvent]]()
    
    var shouldAdjust: Bool = false
    
    fileprivate lazy var calendarStartDate: ComputedDate = {
        let dateformatter: DateFormatter = DateFormatter()
        dateformatter.dateFormat = "dd-MM-yyyy"
        return ComputedDate(date: dateformatter.date(from: "01-01-2006") ?? Date())
    }()
    
    fileprivate lazy var calendarEndDate: ComputedDate = {
        let dateformatter: DateFormatter = DateFormatter()
        dateformatter.dateFormat = "dd-MM-yyyy"
        return ComputedDate(date: dateformatter.date(from: "31-12-2026") ?? Date())

    }()
    
    fileprivate lazy var headerDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMM YYYY"
        return dateFormatter
    }()
    
    fileprivate lazy var totalNumberOfDays: Int = {
        return self.getNumberOfdays(startDate: self.calendarStartDate.date, endDate: self.calendarEndDate.date)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createWeekDaySetupArray()
        self.expandedAspectRatio.priority = .defaultHigh
        self.collapsedAspectRatio.priority = .defaultLow
        weekDayCollectionView.register(UINib(nibName: "WeekViewCell", bundle: nil), forCellWithReuseIdentifier: "WeekViewCell")
        monthCollectionView.register(UINib(nibName: "CalenderCell", bundle: nil), forCellWithReuseIdentifier: "CalenderCell")
        agendaTableView.register(UINib(nibName: "AgendaCell", bundle: nil), forCellReuseIdentifier: "AgendaCell")
        self.weekDayCollectionView.reloadData()
        self.monthCollectionView.reloadData()
        self.agendaTableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) { [weak self] in
            self?.configureUI(true)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.savedEvents.removeAll()
        self.getSavedEvents()
    }
    
    func configureUI (_ isInitialLoad: Bool, shouldShowCurrentDate: Bool = false) {
        var dateComponent = isInitialLoad ? self.currentDate.getDateComponent() : self.selecteddate.getDateComponent()
            var dateToScrollIndex : Int = self.getNumberOfdays(startDate: self.calendarStartDate.date, endDate: CalenderManager.sharedmanager.calendar.date(from: dateComponent)!)
            
            self.agendaTableView.scrollToRow(at: IndexPath(row: 0, section: dateToScrollIndex), at: .top, animated: false)
            if !shouldShowCurrentDate, isInitialLoad {
                dateComponent.day = 1
            }
            dateToScrollIndex = self.getNumberOfdays(startDate: self.calendarStartDate.date, endDate: CalenderManager.sharedmanager.calendar.date(from: dateComponent)!)
            
        self.monthCollectionView.scrollToItem(at: IndexPath(item: dateToScrollIndex, section: 0), at: shouldShowCurrentDate ? .bottom : (isInitialLoad ? .top : .bottom), animated: shouldShowCurrentDate ? true : (isInitialLoad ? false : true))
        self.setNavigationTitle()
        self.shouldAdjust = true
    }
    
    @IBAction func todayButtonAction(_ sender: UIBarButtonItem) {
        self.configureUI(true, shouldShowCurrentDate: true)
    }
    
    @IBAction func addEventButtonAction(_ sender: UIBarButtonItem) {
        self.showEventAddEditScreen(self.selecteddate)
    }
    
    func showEventAddEditScreen(_ date: ComputedDate) {
        let eventAddEditNav: UINavigationController = StoryboardHelper.eventAddEditViewController() as! UINavigationController
        let eventAddEdit: EventAddEditViewController = eventAddEditNav.viewControllers[0] as! EventAddEditViewController
        eventAddEdit.isAllDay = true
        eventAddEdit.selectedDate = date
        eventAddEdit.isNewEvent = true
        self.present(eventAddEditNav, animated: true, completion: nil)        
    }
    
    
    
    func setNavigationTitle() {
        self.title = CalenderManager.sharedmanager.fullMonthWithYearDateFormat.string(from: self.selecteddate.date)
    }
    
    func getNumberOfdays(startDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        guard let start = calendar.ordinality(of: .day, in: .era, for: startDate) else {
            return -1
        }
        guard let end = calendar.ordinality(of: .day, in: .era, for: endDate) else {
            return -1
        }
        return end - start
    }
    func createWeekDaySetupArray() {
        self.weekDayArray.removeAll()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEE"
        for index in 0...6 {
            var date: ComputedDate = ComputedDate(date: CalenderManager.sharedmanager.calendar.date(byAdding: .day, value: index, to: self.calendarStartDate.date) ?? Date())
            var dataSetup: WeekdayDataSetup = WeekdayDataSetup(date: date.date, weekTitle:dateFormatter.string(from: date.date))
            if date.getDateComponent().weekday == self.currentDate.getDateComponent().weekday {
                dataSetup.isSelected = true
            }
            self.weekDayArray.append(dataSetup)
        }
    }
    
    func shouldScrollCollection(animated: Bool, indexPath: IndexPath?) {
        var scrollIndexPath: IndexPath? = indexPath
        if scrollIndexPath == nil,  let visibleIndexPaths = self.agendaTableView.indexPathsForVisibleRows, visibleIndexPaths.count > 0 {
            scrollIndexPath = visibleIndexPaths[0]
        }
        guard let scrollIndexPathUW = scrollIndexPath else {
            return
        }
        let dateComponent = self.selecteddate.getDateComponent()
        let dateToScrollIndex : Int = self.getNumberOfdays(startDate: self.calendarStartDate.date, endDate: CalenderManager.sharedmanager.calendar.date(from: dateComponent)!)
        if scrollIndexPathUW.section != dateToScrollIndex {
            self.selecteddate.date = CalenderManager.sharedmanager.calendar.date(byAdding: .day, value: scrollIndexPathUW.section, to: self.calendarStartDate.date)!
            self.setNavigationTitle()
            let indexPaths = [IndexPath(item: scrollIndexPathUW.section, section: 0), IndexPath(item: dateToScrollIndex, section: 0)]
            self.monthCollectionView.reloadItems(at: indexPaths)
            if animated {
                self.monthCollectionView.scrollToItem(at: indexPaths[0], at: .bottom, animated: animated)
            }
        }
    }
    
    func shouldScrollTableView(indexPath: IndexPath, animated: Bool) {
        self.agendaTableView.scrollToRow(at: indexPath, at: .top, animated: animated)
    }
    
    func getSavedEvents() {
        let savedEventsCD: [CalendarEvent] = CalendarEvent.getAllEvents()
        for event in savedEventsCD {
            let keyString: String = self.headerDateFormatter.string(from: event.startDate! as Date)
            if let calenderEvents: [CalendarEvent] = self.isEventAvailable(event.startDate! as Date) {
                self.savedEvents[keyString] = calenderEvents + [event]
            } else {
                self.savedEvents[keyString] = [event]
            }
        }
        self.monthCollectionView.reloadData()
        self.agendaTableView.reloadData()
    }
    
    func isEventAvailable(_ selectedDate: Date) -> [CalendarEvent]? {
        let keyString: String = self.headerDateFormatter.string(from: selectedDate)
        if let calenderEvents: [CalendarEvent] = self.savedEvents[keyString], calenderEvents.count > 0 {
            return calenderEvents
        }
        return nil
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == weekDayCollectionView {
            return self.weekDayArray.count
        }
        return self.totalNumberOfDays
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == weekDayCollectionView {
            return CGSize(width: UIScreen.main.bounds.width/7, height: 30)
        }
        return CGSize(width: UIScreen.main.bounds.width/7, height: UIScreen.main.bounds.width/7)

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == weekDayCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekViewCell", for: indexPath) as! WeekViewCell
            cell.configureCell(dataSetup: self.weekDayArray[indexPath.row])
                return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalenderCell", for: indexPath) as! CalenderCell
            guard let date = CalenderManager.sharedmanager.calendar.date(byAdding: .day, value: indexPath.row, to: self.calendarStartDate.date) else {
                return cell
            }
            var computedDate: ComputedDate = ComputedDate(date: date)
            let calendarDataSetup: CalendarCellDataSetup = CalendarCellDataSetup(date: computedDate.date, isSelected: computedDate.getDateComponent() == self.selecteddate.getDateComponent(), isCurrentDate: computedDate.getDateComponent() == self.currentDate.getDateComponent(), isOddMonth:computedDate.getDateComponent().month! % 2 != 0, isEventAvailable: (self.isEventAvailable(date) != nil ? true : false))
            cell.configureCell(dataSetup: calendarDataSetup)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        shouldAdjust = false
        self.shouldScrollCollection(animated: false, indexPath: IndexPath(row: 0, section: indexPath.row))
        self.shouldScrollTableView(indexPath: IndexPath(row: 0, section: indexPath.row), animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.totalNumberOfDays
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20))
        headerView.backgroundColor = UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        var computedDate: ComputedDate = ComputedDate(date: Calendar.current.date(byAdding: .day, value: section, to: self.calendarStartDate.date)!)
        let day = self.headerDateFormatter.string(from: computedDate.date)
        headerView.text = day
        if computedDate.getDateComponent() == self.currentDate.getDateComponent() {
            headerView.text = headerView.text! + ", " + "Today"
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let date = CalenderManager.sharedmanager.calendar.date(byAdding: .day, value: section, to: self.calendarStartDate.date) else {
            return 1
        }
        if let calendarEvents = self.isEventAvailable(date), calendarEvents.count > 0  {
            return calendarEvents.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AgendaCell = tableView.dequeueReusableCell(withIdentifier: "AgendaCell") as! AgendaCell
        guard let date = CalenderManager.sharedmanager.calendar.date(byAdding: .day, value: indexPath.section, to: self.calendarStartDate.date) else {
            return cell
        }
        if let calendarEvents = self.isEventAvailable(date), calendarEvents.count > 0  {
            let event: CalendarEvent = calendarEvents[indexPath.row]
            let dataSetup: EventDataSetup = EventDataSetup(title: event.title!, startDate: ComputedDate(date: event.startDate! as Date), enddate: ComputedDate(date: event.endDate! as Date), isAllDay: event.isAllDay, eventId: event.eventId! as Date)
            cell.configureCell(eventdata: dataSetup)
        } else {
            cell.configureCell(eventdata: nil)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // show details
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == self.agendaTableView {
            shouldAdjust = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.agendaTableView, shouldAdjust {
            self.shouldScrollCollection(animated: true, indexPath: nil)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.agendaTableView, shouldAdjust {
            shouldAdjust = false
            UIView.animate(withDuration: 0.5, animations: {
                self.expandedAspectRatio.priority = .defaultLow
                self.collapsedAspectRatio.priority = .defaultHigh
            }, completion: { (_) in
                self.configureUI(false)
            })
            
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.expandedAspectRatio.priority = .defaultHigh
                self.collapsedAspectRatio.priority = .defaultLow
            }, completion: { (_) in
                // do wateve u want
            })
            
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.agendaTableView, shouldAdjust {
            if let visibleIndexPaths = self.agendaTableView.indexPathsForVisibleRows, visibleIndexPaths.count > 0 {
                self.shouldScrollTableView(indexPath: IndexPath(row: 0, section: visibleIndexPaths[0].section), animated: true)
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y < 0.2 {
            if scrollView == self.agendaTableView, shouldAdjust {
                if let visibleIndexPaths = self.agendaTableView.indexPathsForVisibleRows, visibleIndexPaths.count > 0 {
                    self.shouldScrollTableView(indexPath: IndexPath(row: 0, section: visibleIndexPaths[0].section), animated: true)
                }
            }
        }
    }
}
