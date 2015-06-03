//
//  SubmitWorkoutTableViewCell.swift
//  HealthLink
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
