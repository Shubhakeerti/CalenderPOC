//
//  OverlayView.swift
//  CalenderPOC
//
//  Created by Shubhakeerti on 27/03/18.
//  Copyright © 2018 Shubhakeerti. All rights reserved.
//

import UIKit

class OverlayView: UIView {

    @IBOutlet weak var backgroundView: UIView!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
