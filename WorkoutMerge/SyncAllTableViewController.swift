//
//  SyncAllTableViewController.swift
//  WorkoutMerge
//
//  Created by Jason Kusnier on 9/12/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import UIKit
import HealthKit
import CoreData

class SyncAllTableViewController: UITableViewController {

    var workoutSyncAPI: WorkoutSyncAPI?
    
    let hkStore = HKHealthStore()
    var workouts: [(startDate: NSDate, durationLabel: String, workoutTypeLabel: String)] = []
    
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !HKHealthStore.isHealthDataAvailable() {
            print("HealthKit Not Available")
//            self.healthKitAvailable = false
//            self.refreshControl.removeFromSuperview()
        } else {
            let readTypes = Set(arrayLiteral:
                HKObjectType.workoutType(),
                HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!
            )
            
            hkStore.requestAuthorizationToShareTypes(nil, readTypes: readTypes, completion: { (success: Bool, err: NSError?) -> () in
                
                var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
                actInd.center = self.view.center
                actInd.hidesWhenStopped = true
                actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                self.view.addSubview(actInd)
                actInd.startAnimating()
                
                if success {
                    self.readWorkOuts({(results: [AnyObject]!, error: NSError!) -> () in
                        if let results = results as? [HKWorkout] {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.workouts = []
                                for workout in results {
                                    if let managedObject = self.managedObject(workout) {
                                    } else {
                                        self.workouts.append((startDate: workout.startDate, durationLabel: self.stringFromTimeInterval(workout.duration), workoutTypeLabel: HKWorkoutActivityType.hkDescription(workout.workoutActivityType)) as (startDate: NSDate, durationLabel: String, workoutTypeLabel: String))
                                    }
                                }

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.workouts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("syncAllCell", forIndexPath: indexPath) 
        cell.textLabel?.text = self.workouts[indexPath.row].startDate.relativeDateFormat()

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    func readWorkOuts(completion: (([AnyObject]!, NSError!) -> Void)!) {
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        
        let sampleQuery = HKSampleQuery(sampleType: HKWorkoutType.workoutType(), predicate: nil, limit: 0, sortDescriptors: [sortDescriptor])
            { (sampleQuery, results, error ) -> Void in
                if let queryError = error {
                    print( "There was an error while reading the samples: \(queryError.localizedDescription)")
                }
                completion(results, error)
        }
        
        hkStore.executeQuery(sampleQuery)
    }
    
    func managedObject(workout: HKWorkout) -> NSManagedObject? {
        let uuid = workout.UUID.UUIDString
        let servicesPredicate: String
        if let _ = self.workoutSyncAPI as? RunKeeperAPI {
            servicesPredicate = "uuid = %@ AND syncToRunKeeper != nil"
        } else if let _ = self.workoutSyncAPI as? StravaAPI {
            servicesPredicate = "uuid = %@ AND syncToStrava != nil"
        } else {
            return nil
        }
        
        let fetchRequest = NSFetchRequest(entityName: "SyncLog")
        let predicate = NSPredicate(format: servicesPredicate, uuid)
        fetchRequest.predicate = predicate
        
        let fetchedEntities = try? self.managedContext.executeFetchRequest(fetchRequest)
        
        if let syncLog = fetchedEntities?.first as? NSManagedObject {
            return syncLog
        }
        
        return nil
    }
    
    func stringFromTimeInterval(interval:NSTimeInterval) -> String {
        
        let ti = NSInteger(interval)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }
}
