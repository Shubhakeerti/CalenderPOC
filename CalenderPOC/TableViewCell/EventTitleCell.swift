//
//  EventTitleCell.swift
//  CalenderPOC
//
//  Created by Shubhakeerti on 29/03/18.
//  Copyright © 2018 Shubhakeerti. All rights reserved.
//

import UIKit

class EventTitleCell: UITableViewCell {

    @IBOutlet weak var titleTextField: UITextField!
    
    var returnCallBack: ((String) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(title: String, completion: ((String) -> Void)? = nil) {
        self.titleTextField.text = title
        self.returnCallBack = completion
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension EventTitleCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.returnCallBack?(self.titleTextField.text ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.titleTextField.resignFirstResponder()
        return true
    }
}
