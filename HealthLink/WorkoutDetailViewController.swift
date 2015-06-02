//
//  WorkoutDetailViewController.swift
//  HealthLink
//
//  Created by Jason Kusnier on 5/24/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import UIKit
import HealthKit

class WorkoutDetailViewController: UITableViewController {

    var workout:HKWorkout? {
        didSet {
            if let workout = workout {
                self.title = dateFormatter.stringFromDate(workout.startDate)
            }
        }
    }
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var linkedServices: [String]?
    
    var averageHeartRate: Int?
    
    var hkStore:HKHealthStore?
    
    lazy var dateFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .ShortStyle
        return formatter;
    }()
    
    lazy var numberFormatter:NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    lazy var numberFormatterInt:NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let linkedServices = self.defaults.arrayForKey("linkedServices") as? [String] {
            self.linkedServices = linkedServices.sorted() {$0 < $1}
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? UINavigationController {
            if let submitWorkoutViewController = destination.topViewController as? SubmitWorkoutViewController {
                if let workout = workout {
                    submitWorkoutViewController.workoutData = (type: HKWorkoutActivityType.hkDescription(workout.workoutActivityType), startTime: workout.startDate, totalDistance: workout.totalDistance.doubleValueForUnit(HKUnit.meterUnit()), duration: workout.duration, averageHeartRate: averageHeartRate, totalCalories: workout.totalEnergyBurned.doubleValueForUnit(HKUnit.kilocalorieUnit()), notes: nil)
                }
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        if self.linkedServices == nil {
            return 1
        }
        
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        switch section {
        case 0:
            return 7
        case 1:
            return self.linkedServices!.count
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

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
                    cell.detailTextLabel?.text = workout.totalEnergyBurned.description
                case 3:
                    cell.textLabel?.text = "Distance"
                    if let d = numberFormatter.stringFromNumber(workout.totalDistance.doubleValueForUnit(HKUnit.mileUnit())) {
                        cell.detailTextLabel?.text = "\(d) mi"
                    }
                case 4:
                    cell.textLabel?.text = "Avg Heart Rate"
                    func setAvgHeartRage(workout: HKWorkout, cell: UITableViewCell) {
                        self.averageHeartRateForWorkout(workout, success: {d in
                            dispatch_async(dispatch_get_main_queue(),{
                                if let d = d, heartRate = self.numberFormatterInt.stringFromNumber(d) {
                                    cell.detailTextLabel?.text = "\(heartRate) BPM"
                                } else {
                                    cell.detailTextLabel?.text = "N/A"
                                }
                            })
                        })
                    }
                    setAvgHeartRage(workout, cell)
                case 5:
                    cell.textLabel?.text = "Date"
                    cell.detailTextLabel?.text = dateFormatter.stringFromDate(workout.startDate)
                case 6:
                    cell.textLabel?.text = "Source"
                    cell.detailTextLabel?.text = workout.source.name
                default:
                    cell.textLabel?.text = ""
                    cell.detailTextLabel?.text = ""
                }
            }
        } else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("ActionCell", forIndexPath: indexPath) as! UITableViewCell
            if let linkedService = self.linkedServices?[indexPath.row] {
                cell.textLabel?.text = "Sync to \(linkedService)"
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
        if indexPath.section == 1 && indexPath.row == 0 {
            println("Sync to RunKeeper")
            performSegueWithIdentifier("submitWorkout", sender: self)
        }
    }
    
    func stringFromTimeInterval(interval:NSTimeInterval) -> String {
        
        var ti = NSInteger(interval)
        
        var seconds = ti % 60
        var minutes = (ti / 60) % 60
        var hours = (ti / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }

    func averageHeartRateForWorkout(workout: HKWorkout, success: (Double?) -> ()) {
        if let hkStore = hkStore {
            let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
            let workoutPredicate = HKQuery.predicateForSamplesWithStartDate(workout.startDate, endDate: workout.endDate, options: nil)
            let startDateSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
            
            let query = HKSampleQuery(sampleType: quantityType, predicate: workoutPredicate,
                limit: 0, sortDescriptors: [startDateSort]) {
                    (sampleQuery, results, error) -> Void in

                    if let heartRateSamples = results as? [HKQuantitySample] {
                        if heartRateSamples.count > 0 {
                            let avgHeartRate = heartRateSamples.reduce(0) {
                                $0 + $1.quantity.doubleValueForUnit(HKUnit(fromString: "count/min"))
                            } / Double(heartRateSamples.count)

                            self.averageHeartRate = Int(avgHeartRate)

                            success(avgHeartRate)
                        } else {
                            success(nil)
                        }
                    }
            }
            hkStore.executeQuery(query)
        }
    }
}
