//
//  WorkoutDetailViewController.swift
//  WorkoutMerge
//
//  Created by Jason Kusnier on 5/24/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import UIKit
import HealthKit
import CoreData

class WorkoutDetailViewController: UITableViewController {

    var workout:HKWorkout? {
        didSet {
            if let workout = workout {
                self.title = workout.startDate.shortDateString()
            }
        }
    }
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var linkedServices: [String]?
    
    var averageHeartRate: Int?
    
    var hkStore:HKHealthStore?
    
    var useMetric = false
    
    var isFirstLoad = true
    
    var workoutSyncAPI: WorkoutSyncAPI?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let linkedServices = self.defaults.arrayForKey("linkedServices") as? [String] {
            self.linkedServices = linkedServices.sort() {$0 < $1}
        }
        
        self.useMetric = self.defaults.stringForKey("distanceUnit") == "meters"
    }
    
    override func viewWillAppear(animated: Bool) {
        if !isFirstLoad {
            if let linkedServices = self.defaults.arrayForKey("linkedServices") as? [String] {
                self.linkedServices = linkedServices.sort() {$0 < $1}
            }
            
            self.tableView.reloadData()
        }
        isFirstLoad = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? UINavigationController {
            if let submitWorkoutViewController = destination.topViewController as? SubmitWorkoutViewController {
                if let workout = workout {
                    let totalDistance: Double? = (workout.totalDistance != nil) ? workout.totalDistance!.doubleValueForUnit(HKUnit.meterUnit()) : nil
                    let totalEnergyBurned: Double? = workout.totalEnergyBurned != nil ? workout.totalEnergyBurned!.doubleValueForUnit(HKUnit.kilocalorieUnit()) : nil
                    
                    if let workoutSyncAPI = self.workoutSyncAPI {
                        submitWorkoutViewController.workoutData = (workout.UUID, type: workoutSyncAPI.activityType(workout.workoutActivityType), startTime: workout.startDate, totalDistance: totalDistance, duration: workout.duration, averageHeartRate: averageHeartRate, totalCalories: totalEnergyBurned, notes: nil, otherType: nil, activityName: nil)
                        submitWorkoutViewController.workoutSyncAPI = workoutSyncAPI
                    }
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // always two sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 7
        case 1:
            if let linkedServices = self.linkedServices where linkedServices.count > 0 {
                return linkedServices.count
            }
            return 1
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
            cell.selectionStyle = UITableViewCellSelectionStyle.None

            if let workout = workout {
                switch indexPath.row {
                case 0:
                    cell.textLabel?.text = "Workout Type"
                    cell.detailTextLabel?.text = HKWorkoutActivityType.hkDescription(workout.workoutActivityType)
                case 1:
                    cell.textLabel?.text = "Duration"
                    cell.detailTextLabel?.text = stringFromTimeInterval(workout.duration)
                case 2:
                    cell.textLabel?.text = "Calories Burned"
                    if workout.totalEnergyBurned != nil {
                        cell.detailTextLabel?.text = workout.totalEnergyBurned!.doubleValueForUnit(HKUnit.kilocalorieUnit()).intString()
                    }
                case 3:
                    cell.textLabel?.text = "Distance"
                    if workout.totalDistance != nil {
                        if self.useMetric {
                            if let d = workout.totalDistance!.doubleValueForUnit(HKUnit.meterUnit()).intString() {
                                cell.detailTextLabel?.text = "\(d) m"
                            }
                        } else {
                            if let d = workout.totalDistance!.doubleValueForUnit(HKUnit.mileUnit()).shortDecimalString() {
                                cell.detailTextLabel?.text = "\(d) mi"
                            }
                        }
                    }
                case 4:
                    cell.textLabel?.text = "Avg Heart Rate"
                    func setAvgHeartRage(workout: HKWorkout, cell: UITableViewCell) {
                        self.averageHeartRateForWorkout(workout, success: {d in
                            dispatch_async(dispatch_get_main_queue(),{
                                if let d = d, heartRate = d.intString() {
                                    cell.detailTextLabel?.text = "\(heartRate) BPM"
                                } else {
                                    cell.detailTextLabel?.text = "N/A"
                                }
                            })
                        }, tryAgain: true)
                    }
                    setAvgHeartRage(workout, cell: cell)
                case 5:
                    cell.textLabel?.text = "Date"
                    cell.detailTextLabel?.text = workout.startDate.shortDateString()
                case 6:
                    cell.textLabel?.text = "Source"
                    cell.detailTextLabel?.text = workout.source.name
                default:
                    cell.textLabel?.text = ""
                    cell.detailTextLabel?.text = ""
                }
            }
        } else if indexPath.section == 1 {
            if self.linkedServices?.last != nil {
                cell = tableView.dequeueReusableCellWithIdentifier("ActionCell", forIndexPath: indexPath) 
                if let linkedService = self.linkedServices?[indexPath.row] {
                    cell.textLabel?.text = "Sync to \(linkedService)"
                    switch linkedService {
                    case "RunKeeper":
                        cell.tag = 1
                    case "Strava":
                        cell.tag = 2
                    default:
                        cell.tag = 0
                    }
                    
                    if let managedObject = self.managedObject() {
                        let propertiesByName = managedObject.entity.propertiesByName
                        
                        cell.accessoryType = .DisclosureIndicator
                        if propertiesByName["syncTo\(linkedService)"] != nil {
                            if managedObject.valueForKey("syncTo\(linkedService)") != nil {
                                cell.accessoryType = .Checkmark
                            }
                        }
                    }
                }
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("EmptyActionCell", forIndexPath: indexPath) 
            }
        } else {
            cell = UITableViewCell()
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Details"
        case 1:
            return "Actions"
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

        // FIXME adjust this as more services are added
        if self.linkedServices?.last != nil {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                switch cell.tag {
                case 1:
                    print("Sync to RunKeeper")
                    self.workoutSyncAPI = RunKeeperAPI.sharedInstance
                    performSegueWithIdentifier("submitWorkout", sender: self)
                case 2:
                    print("Sync to Strava")
                    self.workoutSyncAPI = StravaAPI.sharedInstance
                    performSegueWithIdentifier("submitWorkout", sender: self)
                default:
                    print("unknown service")
                }
            }
        }
    }
    
    func stringFromTimeInterval(interval:NSTimeInterval) -> String {
        
        let ti = NSInteger(interval)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }

    func averageHeartRateForWorkout(workout: HKWorkout, success: (Double?) -> (), tryAgain: Bool) {
        if let hkStore = hkStore {
            let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
            let workoutPredicate = HKQuery.predicateForSamplesWithStartDate(workout.startDate, endDate: workout.endDate, options: .None)
//            let startDateSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

            let query = HKStatisticsQuery(quantityType: quantityType!, quantitySamplePredicate: workoutPredicate, options: .DiscreteAverage) {
                (query, results, error) -> Void in
                
                if error != nil {
                    print("\(error)")
                    if tryAgain {
                        self.averageHeartRateForWorkout(workout, success: success, tryAgain: false)
                    } else {
                        print("failed to retrieve heart rate data")
                        success(nil)
                    }
                } else {
                    if results!.averageQuantity() != nil {
                        let avgHeartRate = results!.averageQuantity()!.doubleValueForUnit(HKUnit(fromString: "count/min"));
                        
                        self.averageHeartRate = Int(avgHeartRate)
                        success(avgHeartRate)
                    } else if tryAgain {
                        print("averageQuantity unexpectedly found nil")
                        self.averageHeartRateForWorkout(workout, success: success, tryAgain: false)
                    } else {
                        print("failed to retrieve heart rate data")
                        success(nil)
                    }
                }
            }
            hkStore.executeQuery(query)
        }
    }
    
    func managedObject() -> NSManagedObject? {
        if let workout = self.workout {
            let uuid = workout.UUID.UUIDString
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            let fetchRequest = NSFetchRequest(entityName: "SyncLog")
            let predicate = NSPredicate(format: "uuid = %@", uuid)
            fetchRequest.predicate = predicate
            
            let fetchedEntities = try? managedContext.executeFetchRequest(fetchRequest)
            
            if let syncLog = fetchedEntities?.first as? NSManagedObject {
                return syncLog
            }
        }
        
        return nil
    }
}
