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
    
    var isDisabled = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func switchChanged(sender: AnyObject) {
        if let switchChangedCallback = self.switchChangedCallback {            
            if let uiSwitch = sender as? UISwitch {
                self.titleLabel.enabled = uiSwitch.on
                self.subtitleLabel.enabled = uiSwitch.on

                switchChangedCallback(uiSwitch.on)
            }
        }
    }
    
    func setSwitchState(switchState: Bool) {
        if let sendDataSwitch = self.sendDataSwitch {
            sendDataSwitch.on = switchState
        }
        if let titleLabel = self.titleLabel {
            titleLabel.enabled = switchState
        }
        if let subtitleLabel = self.subtitleLabel {
            subtitleLabel.enabled = switchState
        }
    }
    
    func setDisabled(disabledState: Bool) {
        self.isDisabled = disabledState
        if let sendDataSwitch = self.sendDataSwitch {
            sendDataSwitch.enabled = !disabledState
        }
        if let titleLabel = self.titleLabel {
            titleLabel.enabled = !disabledState
        }
        if let subtitleLabel = self.subtitleLabel {
            subtitleLabel.enabled = !disabledState
        }
    }
}
