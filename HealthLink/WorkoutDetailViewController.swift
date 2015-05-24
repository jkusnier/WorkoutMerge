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
    
    lazy var dateFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .ShortStyle
        return formatter;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 6
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell

        if let workout = workout {
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Workout Type"
                cell.detailTextLabel?.text = "\(workout.workoutActivityType)"
            case 1:
                cell.textLabel?.text = "Duration"
                cell.detailTextLabel?.text = stringFromTimeInterval(workout.duration)
            case 2:
                cell.textLabel?.text = "Calories Burned"
                cell.detailTextLabel?.text = workout.totalEnergyBurned.description
            case 3:
                cell.textLabel?.text = "Distance"
                cell.detailTextLabel?.text = workout.totalDistance.description
            case 4:
                cell.textLabel?.text = "Date"
                cell.detailTextLabel?.text = dateFormatter.stringFromDate(workout.startDate)
            case 5:
                cell.textLabel?.text = "Source"
                cell.detailTextLabel?.text = workout.source.description
            default:
                cell.textLabel?.text = ""
                cell.detailTextLabel?.text = ""
            }
        }

        return cell
    }
    
    func stringFromTimeInterval(interval:NSTimeInterval) -> String {
        
        var ti = NSInteger(interval)
        
        var seconds = ti % 60
        var minutes = (ti / 60) % 60
        var hours = (ti / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }

}
