//
//  WeekViewCell.swift
//  CalenderPOC
//
//  Created by Shubhakeerti on 27/03/18.
//  Copyright © 2018 Shubhakeerti. All rights reserved.
//

import UIKit

struct WeekdayDataSetup {
    var date: Date
    var isSelected: Bool
    var weekTitle: String
    init(date: Date, isSelected: Bool = false, weekTitle: String) {
        self.date = date
        self.isSelected = isSelected
        self.weekTitle = weekTitle
    }
}

class WeekViewCell: UICollectionViewCell {

    @IBOutlet weak var weekdayLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(dataSetup: WeekdayDataSetup) {
        if dataSetup.isSelected {
            self.weekdayLabel.textColor = UIColor(red: 54.0/255.0, green: 108.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        } else {
            self.weekdayLabel.textColor = UIColor.black
        }
        weekdayLabel.text = dataSetup.weekTitle
    }

}
