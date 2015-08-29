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
    
    var workoutSyncAPI: WorkoutSyncAPI = WorkoutSyncAPI()
    var resultWorkoutData: (UUID: NSUUID?, type: String?, startTime: NSDate?, totalDistance: Double?, duration: Double?, averageHeartRate: Int?, totalCalories: Double?, notes: String?, otherType: String?, activityName: String?)
    var workoutData: (UUID: NSUUID?, type: String?, startTime: NSDate?, totalDistance: Double?, duration: Double?, averageHeartRate: Int?, totalCalories: Double?, notes: String?, otherType: String?, activityName: String?) {
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
    var picker:Int = 0
    var pickerSelection:Int = 0
    
    var useMetric = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.useMetric = self.defaults.stringForKey("distanceUnit") == "meters"
        
        if let uuid = self.resultWorkoutData.UUID?.UUIDString, syncLog = self.syncLog(uuid) {
            if let note = syncLog.valueForKey("note") as? String {
                self.resultWorkoutData.notes = note
            }
            if let activityName = syncLog.valueForKey("name") as? String {
                self.resultWorkoutData.activityName = activityName
            }
            
            // FIXME find a better way
            if let workoutSyncAPI = self.workoutSyncAPI as? StravaAPI {
                // Strava Workout Types
                if let workoutType = syncLog.valueForKey("workoutTypeStrava") as? String {
                    self.resultWorkoutData.type = workoutType
                }
            } else {
                // Default is RunKeeper
                if let workoutType = syncLog.valueForKey("workoutType") as? String {
                    self.resultWorkoutData.type = workoutType
                }
                if let workoutOtherType = syncLog.valueForKey("workoutOtherType") as? String {
                    self.resultWorkoutData.otherType = workoutOtherType
                }
            }
        }
        
        self.tableView.contentInset = UIEdgeInsetsMake(20, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right)
    }
    
    override func viewDidAppear(animated: Bool) {
        println("workoutData: \(workoutData)")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 7
        
        if let workoutSyncAPI = self.workoutSyncAPI as? StravaAPI {
            // Add 1 for workout Name
            rows++
        }
        
        if resultWorkoutData.type == "Other" {
            // Select other type
            return rows++
        }
        return rows
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
        
        func disabledCell() -> UITableViewCell {
            if let cell = tableView.dequeueReusableCellWithIdentifier("submitStaticInputCell", forIndexPath: indexPath) as? SubmitWorkoutTableViewCell {
                cell.setDisabled(true)
                return cell
            } else {
                return tableView.dequeueReusableCellWithIdentifier("submitStaticCell", forIndexPath: indexPath) as! UITableViewCell
            }
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
        
        var row = indexPath.row
        
        // ugly hack for now to add a conditional cell
        if resultWorkoutData.type == "Other" {
            
            
            if row > 1 {
                // reset so our case works
                row--
            } else if row == 1 {
                cell = staticInputCell()
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.selectionStyle = UITableViewCellSelectionStyle.Default
                setTitle("Other", cell as? SubmitWorkoutTableViewCell)
                setSubtitle(self.resultWorkoutData.otherType == nil ? "" : self.resultWorkoutData.otherType, cell as? SubmitWorkoutTableViewCell)
                return cell
            }
        }
        
        switch row {
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
            if let strava = self.workoutSyncAPI as? StravaAPI {
                cell = disabledCell()
            } else {
                cell = dynamicCell()
            }
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
                if !cell.isDisabled {
                    if let switchState = defaults.valueForKey(self.kSwitchPrefTotalCalories) as? Bool {
                        cell.setSwitchState(switchState)
                    }
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
                    cell.setSwitchState(switchState)
                }
            }
        case 4:
            if let strava = self.workoutSyncAPI as? StravaAPI {
                cell = disabledCell()
            } else {
                cell = dynamicCell()
            }
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
                if !cell.isDisabled {
                    if let switchState = defaults.valueForKey(self.kSwitchPrefAverageHeartRate) as? Bool {
                        cell.setSwitchState(switchState)
                    }
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
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
            setTitle("Notes", cell as? SubmitWorkoutTableViewCell)
            if let notes = self.resultWorkoutData.notes {
                setSubtitle(notes, cell as? SubmitWorkoutTableViewCell)
            } else {
                setSubtitle("", cell as? SubmitWorkoutTableViewCell)
            }
        case 7:
            cell = staticCell()
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            cell.selectionStyle = UITableViewCellSelectionStyle.Default
            setTitle("Name", cell as? SubmitWorkoutTableViewCell)

            if let activityName = self.resultWorkoutData.activityName {
                setSubtitle("\(activityName)", cell as? SubmitWorkoutTableViewCell)
            } else {
                if let startTime = self.workoutData.startTime, type = self.resultWorkoutData.type {
                    setSubtitle("\(startTime.dayOfWeek()) - \(type)", cell as? SubmitWorkoutTableViewCell)
                }
            }
        default:
            cell = dynamicCell()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var row = indexPath.row
        if resultWorkoutData.type == "Other" && row > 1 {
            row--
        }
        
        switch row {
        case 0:
            println("workout selection")
            self.picker = 0
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
                    
                    if let type = self.resultWorkoutData.type, idx = find(self.workoutSyncAPI.activityTypes, type) {
                        self.pickerSelection = idx
                        workoutPicker.selectRow(idx, inComponent: 0, animated: false)
                    }
                    
                    cell.textField.becomeFirstResponder()
                }
            }
        case 1:
            if resultWorkoutData.type == "Other" {
                println("workout other selection")
                self.picker = 1
                
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
                        
                        if let otherType = self.resultWorkoutData.otherType, idx = find(self.workoutSyncAPI.otherTypes, otherType) {
                            self.pickerSelection = idx
                            workoutPicker.selectRow(idx, inComponent: 0, animated: false)
                        } else {
                            self.pickerSelection = 0
                            workoutPicker.selectRow(0, inComponent: 0, animated: false)
                        }
                        
                        cell.textField.becomeFirstResponder()
                    }
                }

            }
        case 6:
            var alert = UIAlertController(title: "Notes", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let doneAction = UIAlertAction(title: "Done", style: .Default) { (action) in
                let notesTextField = alert.textFields![0] as! UITextField
                self.resultWorkoutData.notes = notesTextField.text
                self.tableView.reloadData()
            }
            
            alert.addAction(doneAction)
            alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                textField.placeholder = "Enter notes:"
                if let notes = self.resultWorkoutData.notes {
                    textField.text = notes
                }
            })
            self.presentViewController(alert, animated: true, completion: nil)
        case 7:
            var alert = UIAlertController(title: "Name", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let doneAction = UIAlertAction(title: "Done", style: .Default) { (action) in
                let nameTextField = alert.textFields![0] as! UITextField
                self.resultWorkoutData.activityName = nameTextField.text.isEmpty ? nil : nameTextField.text
                self.tableView.reloadData()
            }
            
            alert.addAction(doneAction)
            alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                textField.placeholder = "Enter name:"
                if let activityName = self.resultWorkoutData.activityName {
                    textField.text = activityName
                }
            })
            self.presentViewController(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func canclePicker() {
        self.view.endEditing(true)
    }
    
    func donePicker() {
        if self.picker == 0 {
            self.resultWorkoutData.type = self.workoutSyncAPI.activityTypes[self.pickerSelection]
            if resultWorkoutData.type != "Other" {
                self.resultWorkoutData.otherType = nil
            }
        } else if self.picker == 1 {
            self.resultWorkoutData.otherType = self.workoutSyncAPI.otherTypes[self.pickerSelection]
        }
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
        
        if let runKeeper = self.workoutSyncAPI as? RunKeeperAPI {
            runKeeper.postActivity(self.resultWorkoutData, failure: { (error, msg) in
                    dispatch_async(dispatch_get_main_queue()) {
                        vcu.hideActivityIndicator(self.view)
                        let errorMessage: String
                        if let error = error {
                            errorMessage = "\(error.localizedDescription) - \(msg)"
                        } else {
                            errorMessage = "An error occurred while saving workout. Please verify that WorkoutMerge is still authorized through RunKeeper - \(msg)"
                        }
                        var alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                },
                success: { (savedKey) in
                    if let uuid = self.resultWorkoutData.UUID?.UUIDString {
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        let managedContext = appDelegate.managedObjectContext!
                        
                        let note = self.resultWorkoutData.notes
                        
                        if let syncLog = self.syncLog(uuid) {
                            syncLog.setValue(NSDate(), forKey: "syncToRunKeeper")
                            syncLog.setValue(note, forKey: "note")
                            syncLog.setValue(savedKey, forKey: "savedKeyRunKeeper")
                            if let workoutType = self.resultWorkoutData.type {
                                syncLog.setValue(workoutType, forKey: "workoutType")
                            }
                            if let workoutOtherType = self.resultWorkoutData.otherType {
                                syncLog.setValue(workoutOtherType, forKey: "workoutOtherType")
                            }
                        } else {
                            let entity =  NSEntityDescription.entityForName("SyncLog", inManagedObjectContext: managedContext)
                            let syncLog = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
                            syncLog.setValue(uuid, forKey: "uuid")
                            syncLog.setValue(NSDate(), forKey: "syncToRunKeeper")
                            syncLog.setValue(note, forKey: "note")
                            syncLog.setValue(savedKey, forKey: "savedKeyRunKeeper")
                            if let workoutType = self.resultWorkoutData.type {
                                syncLog.setValue(workoutType, forKey: "workoutType")
                            }
                            if let workoutOtherType = self.resultWorkoutData.otherType {
                                syncLog.setValue(workoutOtherType, forKey: "workoutOtherType")
                            }
                        }
                        
                        var error: NSError?
                        if !managedContext.save(&error) {
                            println("Could not save \(error)")
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        vcu.hideActivityIndicator(self.view)
                        self.performSegueWithIdentifier("closeSubmitWorkout", sender: self)
                    }
                }
            )
        } else if let strava = self.workoutSyncAPI as? StravaAPI {
            strava.postActivity(self.resultWorkoutData, failure: { (error, msg) in
                    dispatch_async(dispatch_get_main_queue()) {
                        vcu.hideActivityIndicator(self.view)
                        let errorMessage: String
                        if let error = error {
                            errorMessage = "\(error.localizedDescription) - \(msg)"
                        } else {
                            errorMessage = "An error occurred while saving workout. Please verify that WorkoutMerge is still authorized through Strava - \(msg)"
                        }
                        var alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                },
                success: { (savedKey) in
                    if let uuid = self.resultWorkoutData.UUID?.UUIDString {
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        let managedContext = appDelegate.managedObjectContext!
                        
                        let note = self.resultWorkoutData.notes
                        
                        if let syncLog = self.syncLog(uuid) {
                            syncLog.setValue(NSDate(), forKey: "syncToStrava")
                            syncLog.setValue(note, forKey: "note")
                            syncLog.setValue(savedKey, forKey: "savedKeyStrava")
                            if let workoutType = self.resultWorkoutData.type {
                                syncLog.setValue(workoutType, forKey: "workoutTypeStrava")
                            }
                        } else {
                            let entity =  NSEntityDescription.entityForName("SyncLog", inManagedObjectContext: managedContext)
                            let syncLog = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
                            syncLog.setValue(uuid, forKey: "uuid")
                            syncLog.setValue(NSDate(), forKey: "syncToStrava")
                            syncLog.setValue(note, forKey: "note")
                            syncLog.setValue(savedKey, forKey: "savedKeyStrava")
                            if let workoutType = self.resultWorkoutData.type {
                                syncLog.setValue(workoutType, forKey: "workoutTypeStrava")
                            }
                        }
                        
                        var error: NSError?
                        if !managedContext.save(&error) {
                            println("Could not save \(error)")
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        vcu.hideActivityIndicator(self.view)
                        self.performSegueWithIdentifier("closeSubmitWorkout", sender: self)
                    }
                }
            )

        }
    }
    
    @IBAction func saveWorkout(sender: AnyObject) {
        if let uuid = self.resultWorkoutData.UUID?.UUIDString, syncLog = self.syncLog(uuid) {
            var showError = false
            
            if let workoutSyncAPI = self.workoutSyncAPI as? StravaAPI {
                if let workoutType = syncLog.valueForKey("savedKeyStrava") as? String {
                    showError = true
                }
            } else if let workoutSyncAPI = self.workoutSyncAPI as? RunKeeperAPI {
                if let workoutType = syncLog.valueForKey("savedKeyRunKeeper") as? String {
                    showError = true
                }
            }
            
            if showError {
                let alertController = UIAlertController(title: "Alert", message: "Workout already submitted", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                alertController.addAction(UIAlertAction(title: "OK", style: .Default) { (action) in
                    self.doSave()
                })
                
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                self.doSave()
            }
        } else {
            self.doSave()
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.picker == 0 {
            return self.workoutSyncAPI.activityTypes.count
        } else if self.picker == 1 {
            return self.workoutSyncAPI.otherTypes.count
        }

        return 0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if self.picker == 0 {
            return self.workoutSyncAPI.activityTypes[row]
        } else if self.picker == 1 {
            return self.workoutSyncAPI.otherTypes[row]
        }
        
        return nil
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
