//
//  ViewController.swift
//  HealthLink
//
//  Created by Jason Kusnier on 5/23/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let hkStore = HKHealthStore()
    var workouts = [HKWorkout]()
    var selectedWorkout: HKWorkout?
    
    let refreshControl = UIRefreshControl()
    
    lazy var dateFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .ShortStyle
        return formatter;
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        let readTypes = Set([
            HKObjectType.workoutType(),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)
        ])
        
        if !HKHealthStore.isHealthDataAvailable() {
            println("HealthKit Not Available")
        } else {
        
            var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
            actInd.center = self.view.center
            actInd.hidesWhenStopped = true
            actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(actInd)
            actInd.startAnimating()
            
            hkStore.requestAuthorizationToShareTypes(nil, readTypes: readTypes, completion: { (success: Bool, err: NSError!) -> () in
                println("okay: \(success) error: \(err)")
                if success {
                    self.readWorkOuts({(results: [AnyObject]!, error: NSError!) -> () in
                        println("Made It \(results.count)")
                        if let workouts = results as? [HKWorkout] {
                            self.workouts = workouts
                            self.tableView.reloadData()
                        }
                        
                        actInd.stopAnimating()
                    })
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return workouts.count
    }
    
    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell
        let workout  = self.workouts[indexPath.row]
        let startDate = dateFormatter.stringFromDate(workout.startDate)
        
        cell.textLabel!.text = startDate
        cell.detailTextLabel!.text = stringFromTimeInterval(workout.duration)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedWorkout = self.workouts[indexPath.row]
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.performSegueWithIdentifier("workoutDetail", sender: self)
    }
    
    func stringFromTimeInterval(interval:NSTimeInterval) -> String {
        
        var ti = NSInteger(interval)
        
        var seconds = ti % 60
        var minutes = (ti / 60) % 60
        var hours = (ti / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        self.readWorkOuts({(results: [AnyObject]!, error: NSError!) -> () in
            println("Made It \(results.count)")
            if let workouts = results as? [HKWorkout] {
                self.workouts = workouts
                self.tableView.reloadData()
            }
            
            self.refreshControl.endRefreshing()
        })
    }
}

