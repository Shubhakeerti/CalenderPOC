//
//  StoryboardHelper.swift
//  CalenderPOC
//
//  Created by Shubhakeerti on 28/03/18.
//  Copyright © 2018 Shubhakeerti. All rights reserved.
//

import UIKit

class StoryboardHelper {

    static func storyboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
    
    static func eventAddEditViewController() -> UIViewController {
        return StoryboardHelper.storyboard().instantiateViewController(withIdentifier: "EventAddEditViewControllerNav")
    }
    
    static func dateTimeSelectionViewController() -> UIViewController {
        return StoryboardHelper.storyboard().instantiateViewController(withIdentifier: "DateTimeSelectionControllerNav")
    }
}
