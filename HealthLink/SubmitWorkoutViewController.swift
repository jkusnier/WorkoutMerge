//
//  SubmitWorkoutViewController.swift
//  HealthLink
//
//  Created by Jason Kusnier on 5/29/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//
//  This will need a refactor once we submit to more than one service. Intentionally coding to RunKeeper for first iteration.

import UIKit

class SubmitWorkoutViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var resultWorkoutData: (type: String?, startTime: NSDate?, totalDistance: Double?, duration: Double?, averageHeartRate: Int?, totalCalories: Double?, notes: String?)
    var workoutData: (type: String?, startTime: NSDate?, totalDistance: Double?, duration: Double?, averageHeartRate: Int?, totalCalories: Double?, notes: String?) {
        didSet {
            self.resultWorkoutData = self.workoutData
        }
    }
    var pickerSelection:Int = 0
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var useMetric = false

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarHidden = true
        self.useMetric = self.defaults.stringForKey("distanceUnit") == "meters"
    }
    
    override func viewDidAppear(animated: Bool) {
        println("workoutData: \(workoutData)")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Sync Data"
        default:
            return ""
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell
        
        func staticCell() -> UITableViewCell {
            return tableView.dequeueReusableCellWithIdentifier("submitStaticCell", forIndexPath: indexPath) as! UITableViewCell
        }
        
        func dynamicCell() -> UITableViewCell {
            return tableView.dequeueReusableCellWithIdentifier("submitDynamicCell", forIndexPath: indexPath) as! UITableViewCell
        }
        
        func staticInputCell() -> UITableViewCell {
            return tableView.dequeueReusableCellWithIdentifier("submitStaticInputCell", forIndexPath: indexPath) as! UITableViewCell
        }
        
        func setTitle(title: String?, cell: SubmitWorkoutTableViewCell?) {
            if let l = cell?.titleLabel, t = title {
                l.text = t
            }
        }
        
        func setSubtitle(title: String?, cell: SubmitWorkoutTableViewCell?) {
            if let l = cell?.subtitleLabel, t = title {
                l.text = t
            }
        }
//        (type: String?, startTime: NSDate?, totalDistance: Double?, duration: Double?, averageHeartRate: Int?, totalCalories: Double?, notes: String?)
        
        switch indexPath.row {
        case 0:
            cell = staticInputCell()
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
            setTitle("Workout Type", cell as? SubmitWorkoutTableViewCell)
            setSubtitle(self.resultWorkoutData.type, cell as? SubmitWorkoutTableViewCell)
        case 1:
            cell = staticCell()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            setTitle("Duration", cell as? SubmitWorkoutTableViewCell)
            setSubtitle(stringFromTimeInterval(self.resultWorkoutData.duration), cell as? SubmitWorkoutTableViewCell)
        case 2:
            cell = dynamicCell()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            setTitle("Calories Burned", cell as? SubmitWorkoutTableViewCell)
            if let totalCalories = self.workoutData.totalCalories {
                setSubtitle(totalCalories.intString(), cell as? SubmitWorkoutTableViewCell)
            }
            if let cell = cell as? SubmitWorkoutTableViewCell {
                cell.switchChangedCallback = { isOn in
                    self.resultWorkoutData.totalCalories = isOn ? self.workoutData.totalCalories : nil
                }
            }
        case 3:
            cell = dynamicCell()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            setTitle("Distance", cell as? SubmitWorkoutTableViewCell)
            if let totalDistance = self.workoutData.totalDistance {
                if self.useMetric {
                    setSubtitle(totalDistance.intString()! + " meters", cell as? SubmitWorkoutTableViewCell)
                } else {
                    let miles = totalDistance * 0.00062137
                    setSubtitle(miles.shortDecimalString()! + " miles", cell as? SubmitWorkoutTableViewCell)
                }
            }
            if let cell = cell as? SubmitWorkoutTableViewCell {
                cell.switchChangedCallback = { isOn in
                    self.resultWorkoutData.totalDistance = isOn ? self.workoutData.totalDistance : nil
                }
            }
        case 4:
            cell = dynamicCell()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            setTitle("Avg Heart Rate", cell as? SubmitWorkoutTableViewCell)
            if let averageHeartRate = self.workoutData.averageHeartRate {
                setSubtitle(averageHeartRate.intString()! + " BPM", cell as? SubmitWorkoutTableViewCell)
            }
            if let cell = cell as? SubmitWorkoutTableViewCell {
                cell.switchChangedCallback = { isOn in
                    self.resultWorkoutData.averageHeartRate = isOn ? self.workoutData.averageHeartRate : nil
                }
            }
        case 5:
            cell = staticCell()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            setTitle("Date", cell as? SubmitWorkoutTableViewCell)
            if let startTime = self.workoutData.startTime {
                setSubtitle(startTime.shortDateString(), cell as? SubmitWorkoutTableViewCell)
            }
        case 6:
            cell = staticCell()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            setTitle("Notes", cell as? SubmitWorkoutTableViewCell)
            setSubtitle("", cell as? SubmitWorkoutTableViewCell)
        default:
            cell = dynamicCell()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            println("workout selection")
            var workoutPicker = UIPickerView()
            workoutPicker.delegate = self
            workoutPicker.dataSource = self
            
            var toolBar = UIToolbar()
            toolBar.sizeToFit()
            
            var doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: "donePicker")
            var spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            var cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "canclePicker")

            toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
            toolBar.userInteractionEnabled = true
            
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? SubmitWorkoutTableViewCell {
                if cell.textField != nil {
                    cell.textField.inputView = workoutPicker
                    cell.textField.inputAccessoryView = toolBar
                    
                    if let type = self.resultWorkoutData.type, idx = find(RunKeeperAPI.activityTypes, type) {
                        self.pickerSelection = idx
                        workoutPicker.selectRow(idx, inComponent: 0, animated: false)
                    }
                    
                    cell.textField.becomeFirstResponder()
                }
            }
        default:
            break
        }
    }
    
    func canclePicker() {
        self.view.endEditing(true)
    }
    
    func donePicker() {
        self.resultWorkoutData.type = RunKeeperAPI.activityTypes[self.pickerSelection]
        self.tableView.reloadData()
        self.view.endEditing(true)
    }
    
    func stringFromTimeInterval(interval:NSTimeInterval?) -> String {
        if let i = interval {
            var ti = NSInteger(i)
            
            var seconds = ti % 60
            var minutes = (ti / 60) % 60
            var hours = (ti / 3600)
            
            return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
        } else {
            return "00:00:00"
        }
    }
    
    @IBAction func saveWorkout(sender: AnyObject) {
        let runKeeper = RunKeeperAPI.sharedInstance
        runKeeper.authorize()
        runKeeper.postActivity(resultWorkoutData, failure: { error in
            },
            success: {
                self.performSegueWithIdentifier("closeSubmitWorkout", sender: self)
            }
        )
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return RunKeeperAPI.activityTypes.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return RunKeeperAPI.activityTypes[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.pickerSelection = row
    }
}
