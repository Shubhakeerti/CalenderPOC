//
//  AgendaCell.swift
//  CalenderPOC
//
//  Created by Shubhakeerti on 28/03/18.
//  Copyright © 2018 Shubhakeerti. All rights reserved.
//

import UIKit

class AgendaCell: UITableViewCell {

    @IBOutlet weak var noEventsLabel: UILabel!
    @IBOutlet weak var eventContainerView: UIView!
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var fromTime: UILabel!
    @IBOutlet weak var toTime: UILabel!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var eventTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(eventdata: EventDataSetup?) {
        if let eventDataUW = eventdata {
            noEventsLabel.isHidden = true
            eventContainerView.isHidden = false
            if eventDataUW.isAllDay {
                toTime.isHidden = true
                fromTime.text = "All-day"
            } else {
                toTime.isHidden = false
                fromTime.text = CalenderManager.sharedmanager.timeFormat.string(from: eventDataUW.startDate.date)
                toTime.text = CalenderManager.sharedmanager.timeFormat.string(from: eventDataUW.enddate.date)
            }
            eventTitle.text = eventDataUW.title
        } else {
            eventContainerView.isHidden = true
            noEventsLabel.isHidden = false
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
