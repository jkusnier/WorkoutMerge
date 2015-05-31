//
//  SubmitWorkoutViewController.swift
//  HealthLink
//
//  Created by Jason Kusnier on 5/29/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//
//  This will need a refactor once we submit to more than one service. Intentionally coding to RunKeeper for first iteration.

import UIKit

class SubmitWorkoutViewController: UITableViewController {
    
    var workoutData: (type: String?, startTime: NSDate?, totalDistance: Double?, duration: Double?, averageHeartRate: Int?, totalCalories: Double?, notes: String?)
    
    lazy var dateFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        formatter.dateStyle = .ShortStyle
        return formatter;
        }()
        
    lazy var numberFormatterInt:NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 0
        return formatter
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarHidden = true
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
            cell = staticCell()
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            setTitle("Workout Type", cell as? SubmitWorkoutTableViewCell)
            setSubtitle(self.workoutData.type, cell as? SubmitWorkoutTableViewCell)
        case 1:
            cell = staticCell()
            setTitle("Duration", cell as? SubmitWorkoutTableViewCell)
            setSubtitle(stringFromTimeInterval(self.workoutData.duration), cell as? SubmitWorkoutTableViewCell)
        case 2:
            cell = dynamicCell()
            setTitle("Calories Burned", cell as? SubmitWorkoutTableViewCell)
            if let totalCalories = self.workoutData.totalCalories {
                setSubtitle(numberFormatterInt.stringFromNumber(totalCalories), cell as? SubmitWorkoutTableViewCell)
            }
        case 3:
            cell = dynamicCell()
            setTitle("Distance", cell as? SubmitWorkoutTableViewCell)
            if let totalDistance = self.workoutData.totalDistance {
                setSubtitle(numberFormatterInt.stringFromNumber(totalDistance)! + " meters", cell as? SubmitWorkoutTableViewCell)
            }
        case 4:
            cell = dynamicCell()
            setTitle("Avg Heart Rate", cell as? SubmitWorkoutTableViewCell)
            if let averageHeartRate = self.workoutData.averageHeartRate {
                setSubtitle(numberFormatterInt.stringFromNumber(averageHeartRate)! + " BPM", cell as? SubmitWorkoutTableViewCell)
            }
        case 5:
            cell = staticCell()
            setTitle("Date", cell as? SubmitWorkoutTableViewCell)
            if let startTime = self.workoutData.startTime {
                setSubtitle(dateFormatter.stringFromDate(startTime), cell as? SubmitWorkoutTableViewCell)
            }
        case 6:
            cell = staticCell()
            setTitle("Notes", cell as? SubmitWorkoutTableViewCell)
            setSubtitle("", cell as? SubmitWorkoutTableViewCell)
        default:
            cell = dynamicCell()
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
}
