//
//  SubmitWorkoutTableViewCell.swift
//  WorkoutMerge
//
//  Created by Jason Kusnier on 5/30/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import UIKit

class SubmitWorkoutTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var sendDataSwitch: UISwitch!
    @IBOutlet weak var textField: UITextField!
    
    var switchChangedCallback: ((Bool) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func switchChanged(sender: AnyObject) {
        if let switchChangedCallback = self.switchChangedCallback {
            if let uiSwitch = sender as? UISwitch {
                switchChangedCallback(uiSwitch.on)
            }
        }
    }
}
