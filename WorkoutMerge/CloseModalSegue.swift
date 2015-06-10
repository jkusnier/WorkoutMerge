//
//  CloseModalSegue.swift
//  WorkoutMerge
//
//  Created by Jason Kusnier on 5/23/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import UIKit

class CloseModalSegue: UIStoryboardSegue {
    override func perform() {
        if let source = self.sourceViewController as? UIViewController {
            source.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
