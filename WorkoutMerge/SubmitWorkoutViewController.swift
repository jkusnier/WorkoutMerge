//
//  SubmitWorkoutViewController.swift
//  WorkoutMerge
//
//  Created by Jason Kusnier on 5/29/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//
//  This will need a refactor once we submit to more than one service. Intentionally coding to RunKeeper for first iteration.

import UIKit
import CoreData

class SubmitWorkoutViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let kSwitchPrefTotalCalories = "kSwitchPrefTotalCalories"
    let kSwitchPrefTotalDistance = "kSwitchPrefTotalDistance"
    let kSwitchPrefAverageHeartRate = "kSwitchPrefAverageHeartRate"
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var resultWorkoutData: (UUID: NSUUID?, type: String?, startTime: NSDate?, totalDistance: Double?, duration: Double?, averageHeartRate: Int?, totalCalories: Double?, notes: String?)
    var workoutData: (UUID: NSUUID?, type: String?, startTime: NSDate?, totalDistance: Double?, duration: Double?, averageHeartRate: Int?, totalCalories: Double?, notes: String?) {
        didSet {
            self.resultWorkoutData = self.workoutData
            
            // Check defaults for switches
            if let switchPrefTotalCalories = defaults.valueForKey(kSwitchPrefTotalCalories) as? Bool where !switchPrefTotalCalories {
                self.resultWorkoutData.totalCalories = nil
            }
            if let switchPrefTotalDistance = defaults.valueForKey(kSwitchPrefTotalDistance) as? Bool where !switchPrefTotalDistance {
                self.resultWorkoutData.totalDistance = nil
            }
            if let switchPrefAverageHeartRate = defaults.valueForKey(kSwitchPrefAverageHeartRate) as? Bool where !switchPrefAverageHeartRate {
                self.resultWorkoutData.averageHeartRate = nil
            }
        }
    }
    var pickerSelection:Int = 0
    
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
                    self.defaults.setBool(isOn, forKey: self.kSwitchPrefTotalCalories)
                }
                if let switchState = defaults.valueForKey(self.kSwitchPrefTotalCalories) as? Bool {
                    cell.sendDataSwitch.on = switchState
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
                    self.defaults.setBool(isOn, forKey: self.kSwitchPrefTotalDistance)
                }
                if let switchState = defaults.valueForKey(self.kSwitchPrefTotalDistance) as? Bool {
                    cell.sendDataSwitch.on = switchState
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
                    self.defaults.setBool(isOn, forKey: self.kSwitchPrefAverageHeartRate)
                }
                if let switchState = defaults.valueForKey(self.kSwitchPrefAverageHeartRate) as? Bool {
                    cell.sendDataSwitch.on = switchState
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
    
    func doSave() {
        let vcu = ViewControllerUtils()
        
        vcu.showActivityIndicator(self.view)
        
        let runKeeper = RunKeeperAPI.sharedInstance
        runKeeper.authorize({ wasFailure, error in
            if wasFailure {
                println("\(wasFailure)")
                vcu.hideActivityIndicator(self.view)
            } else {
                runKeeper.postActivity(self.resultWorkoutData, failure: { error in
                    vcu.hideActivityIndicator(self.view)
                    },
                    success: {
                        if let uuid = self.resultWorkoutData.UUID?.UUIDString {
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            let managedContext = appDelegate.managedObjectContext!
                            
                            if let syncLog = self.syncLog(uuid) {
                                syncLog.setValue(NSDate(), forKey: "syncToRunKeeper")
                            } else {
                                let entity =  NSEntityDescription.entityForName("SyncLog", inManagedObjectContext: managedContext)
                                let syncLog = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
                                syncLog.setValue(uuid, forKey: "uuid")
                                syncLog.setValue(NSDate(), forKey: "syncToRunKeeper")
                            }
                            
                            var error: NSError?
                            if !managedContext.save(&error) {
                                println("Could not save \(error)")
                            }
                        }
                        
                        vcu.hideActivityIndicator(self.view)
                        self.performSegueWithIdentifier("closeSubmitWorkout", sender: self)
                    }
                )
            }
        })
    }
    
    @IBAction func saveWorkout(sender: AnyObject) {
        if let uuid = self.resultWorkoutData.UUID?.UUIDString, syncLog = self.syncLog(uuid) {
            let alertController = UIAlertController(title: "Alert", message: "Workout already submitted", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                // Do nothing
            })
            
            alertController.addAction(UIAlertAction(title: "OK", style: .Default) { (action) in
                self.doSave()
            })
            
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.doSave()
        }
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
    
    func syncLog(uuid: String) -> NSManagedObject? {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "SyncLog")
        let predicate = NSPredicate(format: "uuid = %@", uuid)
        fetchRequest.predicate = predicate
        
        let fetchedEntities = managedContext.executeFetchRequest(fetchRequest, error: nil)
        
        if let syncLog = fetchedEntities?.first as? NSManagedObject {
            return syncLog
        }

        return nil
    }
}
