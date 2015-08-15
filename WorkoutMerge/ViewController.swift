//
//  ViewController.swift
//  WorkoutMerge
//
//  Created by Jason Kusnier on 5/23/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import UIKit
import HealthKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let hkStore = HKHealthStore()
    var workouts = [HKWorkout]()
    var selectedWorkout: HKWorkout?
    
    let refreshControl = UIRefreshControl()
    var lastRefreshDate: NSDate?
    
    var healthKitAvailable = true
    
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    var initialAppearance = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        self.tableView.addSubview(refreshControl)
        
        let readTypes = Set([
            HKObjectType.workoutType(),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        ])
        
        if !HKHealthStore.isHealthDataAvailable() {
            println("HealthKit Not Available")
            self.healthKitAvailable = false
            self.refreshControl.removeFromSuperview()
        } else {
            hkStore.requestAuthorizationToShareTypes(nil, readTypes: readTypes, completion: { (success: Bool, err: NSError!) -> () in
//                println("okay: \(success) error: \(err)")
                
                var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
                actInd.center = self.view.center
                actInd.hidesWhenStopped = true
                actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                self.view.addSubview(actInd)
                actInd.startAnimating()
                
                if success {
                    self.readWorkOuts({(results: [AnyObject]!, error: NSError!) -> () in
                        println("Found \(results.count) workouts")
                        if let workouts = results as? [HKWorkout] {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.workouts = workouts
                                self.lastRefreshDate = NSDate()
                                self.refreshControl.attributedTitle = NSAttributedString(string: "Last Refresh: \(self.lastRefreshDate!.timeFormat())")
                                self.tableView.reloadData()
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            actInd.stopAnimating()
                        }
                    })
                } else {
                    actInd.stopAnimating()
                }
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !self.initialAppearance {
            // Refresh for tableview accessories
            self.tableView.reloadData()
        } else {
            self.initialAppearance = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let workoutDetail = segue.destinationViewController as? WorkoutDetailViewController {
            if let selection = selectedWorkout {
                workoutDetail.workout = selection
                workoutDetail.hkStore = hkStore
            }
        }
        
        super.prepareForSegue(segue, sender: sender)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == "workoutDetail" {
            if let selection = selectedWorkout {
                return true
            }
            return false
        }
        
        return true
    }

    func readWorkOuts(completion: (([AnyObject]!, NSError!) -> Void)!) {

//        let predicate =  HKQuery.predicateForWorkoutsWithWorkoutActivityType(HKWorkoutActivityType.)

        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)

        let sampleQuery = HKSampleQuery(sampleType: HKWorkoutType.workoutType(), predicate: nil, limit: 50, sortDescriptors: [sortDescriptor])
            { (sampleQuery, results, error ) -> Void in
                
                if let queryError = error {
                    println( "There was an error while reading the samples: \(queryError.localizedDescription)")
                }
                completion(results, error)
        }

        hkStore.executeQuery(sampleQuery)
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        var numRows = workouts.count
        
        if numRows == 0 {
            numRows = 1
        }
        
        return numRows
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        if !self.healthKitAvailable {
            return tableView.dequeueReusableCellWithIdentifier("NoHealthKit") as! UITableViewCell
        } else if self.workouts.last != nil {
            if let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? WorkoutTableViewCell {
                let workout  = self.workouts[indexPath.row]
                let startDate = workout.startDate.relativeDateFormat()
                
                if let managedObject = managedObject(workout) {
                    cell.accessoryType = .Checkmark
                } else {
                    cell.accessoryType = .DisclosureIndicator
                }
                
                cell.startTimeLabel?.text = startDate
                cell.durationLabel?.text = stringFromTimeInterval(workout.duration)
                cell.workoutTypeLabel?.text = HKWorkoutActivityType.hkDescription(workout.workoutActivityType)
                
                return cell
            } else {
                return tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
            }
        } else {
            return tableView.dequeueReusableCellWithIdentifier("Empty") as! UITableViewCell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.workouts.last != nil {
            self.selectedWorkout = self.workouts[indexPath.row]
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.performSegueWithIdentifier("workoutDetail", sender: self)
        }
    }
    
    func stringFromTimeInterval(interval:NSTimeInterval) -> String {
        
        var ti = NSInteger(interval)
        
        var seconds = ti % 60
        var minutes = (ti / 60) % 60
        var hours = (ti / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        let readTypes = Set([
            HKObjectType.workoutType(),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
            ])
        
        hkStore.requestAuthorizationToShareTypes(nil, readTypes: readTypes, completion: { (success: Bool, err: NSError!) -> () in
            if success {
                self.readWorkOuts({(results: [AnyObject]!, error: NSError!) -> () in
                    if (error != nil) {
                        println(error.localizedDescription)
                        var alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                    if let workouts = results as? [HKWorkout] {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.workouts = workouts
                            self.lastRefreshDate = NSDate()
                            self.refreshControl.attributedTitle = NSAttributedString(string: "Last Refresh: \(self.lastRefreshDate!.timeFormat())")
                            self.tableView.reloadData()
                        }
                    } else {
                        self.workouts.removeAll(keepCapacity: false)
                    }

                    dispatch_async(dispatch_get_main_queue()) {
                        self.refreshControl.endRefreshing()
                    }
                })
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.refreshControl.endRefreshing()
                }
            }
        })
    }
    
    func managedObject(workout: HKWorkout) -> NSManagedObject? {
        if let uuid = workout.UUID?.UUIDString {
            let fetchRequest = NSFetchRequest(entityName: "SyncLog")
            let predicate = NSPredicate(format: "uuid = %@", uuid)
            fetchRequest.predicate = predicate
            
            let fetchedEntities = self.managedContext.executeFetchRequest(fetchRequest, error: nil)
            
            if let syncLog = fetchedEntities?.first as? NSManagedObject {
                return syncLog
            }
        }
        
        return nil
    }
}

