//
//  CalenderCell.swift
//  CalenderPOC
//
//  Created by Shubhakeerti on 27/03/18.
//  Copyright © 2018 Shubhakeerti. All rights reserved.
//

import UIKit

struct CalendarCellDataSetup {
    var date: Date
    var isSelected: Bool
    var isCurrentDate: Bool
    var isOddMonth: Bool
    var isEventAvailable: Bool
    init(date: Date, isSelected: Bool = false, isCurrentDate: Bool = false, isOddMonth: Bool, isEventAvailable: Bool) {
        self.date = date
        self.isSelected = isSelected
        self.isCurrentDate = isCurrentDate
        self.isOddMonth = isOddMonth
        self.isEventAvailable = isEventAvailable
    }
}

class CalenderCell: UICollectionViewCell {

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateLabelVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var eventIndicator: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        monthLabel.isHidden = true
        dateLabelVerticalConstraint.constant = 0.0
        // Initialization code
    }
    
    func configureCell(dataSetup: CalendarCellDataSetup) {
        monthLabel.isHidden = true
        dateLabelVerticalConstraint.constant = 0.0
        self.eventIndicator.isHidden = true
        if dataSetup.isOddMonth {
            self.containerView.backgroundColor = UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0)
        } else {
            self.containerView.backgroundColor = UIColor.white
        }
        let dateComponents: DateComponents = CalenderManager.sharedmanager.getDateComponents(date: dataSetup.date)
        dateLabel.text = String(format:"%d",dateComponents.day!)
        if dateComponents.day == 1 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM"
            monthLabel.isHidden = false
            monthLabel.text = dateFormatter.string(from: dataSetup.date)
            dateLabelVerticalConstraint.constant = 6.0
        }
        
        self.selectionView.backgroundColor = UIColor.clear
        self.dateLabel.textColor = UIColor.black
        if dataSetup.isCurrentDate {
            monthLabel.isHidden = true
            dateLabelVerticalConstraint.constant = 0.0
            self.dateLabel.textColor = UIColor.white
            self.selectionView.backgroundColor = UIColor(red: 208.0/255.0, green: 46.0/255.0, blue: 42.0/255.0, alpha: 1.0)
            return
        }
        if dataSetup.isSelected {
            monthLabel.isHidden = true
            dateLabelVerticalConstraint.constant = 0.0
            self.dateLabel.textColor = UIColor.white
            self.selectionView.backgroundColor = UIColor(red: 54.0/255.0, green: 108.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        }
        
        if dataSetup.isEventAvailable {
            self.eventIndicator.isHidden = false
        }
    }

}
