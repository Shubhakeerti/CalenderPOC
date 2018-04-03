//
//  DateTimeSelectionController.swift
//  CalenderPOC
//
//  Created by Shubhakeerti on 29/03/18.
//  Copyright © 2018 Shubhakeerti. All rights reserved.
//

import UIKit

protocol DateSelectorProtocol: NSObjectProtocol{
    func didSelectDate(selectedDate: ComputedDate, selectionType: SelectionType)
    func didSelectRange(startDate: ComputedDate, endDate: ComputedDate)
}
class DateTimeSelectionController: UIViewController {

    @IBOutlet weak var timeSelectionContainerView: UIView!
    @IBOutlet weak var fromPicker: UIDatePicker!
    @IBOutlet weak var toPicker: UIDatePicker!
    @IBOutlet weak var dateSelectionContainerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var selectedDateLabel: UILabel!
    
    @IBOutlet weak var arrowLabel: UILabel!
    weak var delegate: DateSelectorProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let dateformatter: DateFormatter = DateFormatter()
        dateformatter.dateFormat = "EEE, d MMM yyyy"
        return dateformatter
    }()
    
    private lazy var timeFormatter: DateFormatter = {
        let timeFormatter: DateFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        return timeFormatter
    }()
    
    var startDate: ComputedDate = ComputedDate(date: Date())
    var endDate: ComputedDate = ComputedDate(date: Date())
    
    var selectionType: SelectionType = .Date
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.selectionType == .Time {
            self.title = "Select Time"
            arrowLabel.text = "\u{2192}"
            timeSelectionContainerView.isHidden = false
            fromPicker.setDate(startDate.date, animated: true)
            toPicker.setDate(endDate.date, animated: true)
            fromPicker.addTarget(self, action: #selector(fromPickerDateChange), for: .valueChanged)
            toPicker.addTarget(self, action: #selector(toPickerDateChange), for: .valueChanged)
        } else {
            self.title = "Select Date"
            dateSelectionContainerView.isHidden = false
            if self.selectionType == .StartDate {
                datePicker.setDate(startDate.date, animated: true)
            } else {
                datePicker.setDate(endDate.date, animated: true)
            }
            datePicker.addTarget(self, action: #selector(datePickerDateChange), for: .valueChanged)
        }
        self.updateLabel()
    }
    
    //MARK:- UI Configuration Methods
    private func updateLabel() {
        if self.selectionType == .StartDate {
            self.selectedDateLabel.text = self.dateFormatter.string(from: self.startDate.date)
        } else if self.selectionType == .EndDate {
            self.selectedDateLabel.text = self.dateFormatter.string(from: self.endDate.date)
        } else {
            self.selectedDateLabel.text = self.timeFormatter.string(from: self.startDate.date) + " \u{2192} " + self.timeFormatter.string(from: self.endDate.date)
        }
    }
    
    //MARK:- Action Methods
    @IBAction func dismissAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        if self.selectionType == .StartDate {
            self.delegate?.didSelectDate(selectedDate: self.startDate, selectionType: self.selectionType)
        } else if self.selectionType == .EndDate {
            self.delegate?.didSelectDate(selectedDate: self.endDate, selectionType: self.selectionType)
        } else {
            self.delegate?.didSelectRange(startDate: self.startDate, endDate: self.endDate)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func fromPickerDateChange() {
        startDate.date = fromPicker.date
        var endDateComponent = endDate.getDateComponentWithTime()
        if startDate.getDateComponentWithTime().hour! > endDate.getDateComponentWithTime().hour! {
            endDateComponent.hour = startDate.getDateComponentWithTime().hour
            endDateComponent.minute = startDate.getDateComponentWithTime().minute! + 1
            endDate = ComputedDate(date: CalenderManager.sharedmanager.calendar.date(from: endDateComponent)!)
            toPicker.setDate(endDate.date, animated: true)
        } else if startDate.getDateComponentWithTime().hour! == endDate.getDateComponentWithTime().hour! {
            endDateComponent.minute = startDate.getDateComponentWithTime().minute! + 1
            endDate = ComputedDate(date: CalenderManager.sharedmanager.calendar.date(from: endDateComponent)!)
            toPicker.setDate(endDate.date, animated: true)
        }
        self.updateLabel()
    }
    
    @objc func toPickerDateChange() {
        endDate.date = toPicker.date
        self.updateLabel()
    }
    
    @objc func datePickerDateChange() {
        if self.selectionType == .StartDate {
            startDate.date = datePicker.date
        } else if self.selectionType == .EndDate {
            endDate.date = datePicker.date
        }
        self.updateLabel()
    }
}
