//
//  SettingsViewController.swift
//  WorkoutMerge
//
//  Created by Jason Kusnier on 5/23/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import UIKit
import HealthKit
import p2_OAuth2

class SettingsViewController: UITableViewController {
    
    let hkStore = HKHealthStore()
    let defaults = NSUserDefaults.standardUserDefaults()
    var linkedServices: [String]?

    @IBOutlet weak var runKeeperStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let linkedServices = self.defaults.arrayForKey("linkedServices") as? [String] {
            self.linkedServices = linkedServices
            
            if contains(linkedServices, "RunKeeper") {
                self.runKeeperStatusLabel.text = "Linked"
            } else {
                self.runKeeperStatusLabel.text = "Connect"
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            println("Apple Health")
            var alert = UIAlertController(title: "Apple Health", message: "Please adjust the settings using the Heath app.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else if indexPath.section == 0 && indexPath.row == 1 {
            println("RunKeeper")

            if self.linkedServices == nil {
                self.linkedServices = [String]()
            }
            
            if let linkedServices = self.linkedServices {
                let rk = RunKeeperAPI.sharedInstance

                if contains(linkedServices, "RunKeeper") {
                    let alertController = UIAlertController(title: "Alert", message: "Are you sure you want to unlink RunKeeper?", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default) { (action) in
                        rk.disconnect()
                        if let i = find(linkedServices, "RunKeeper") {
                            self.linkedServices?.removeAtIndex(i)
                            self.defaults.setObject(self.linkedServices, forKey: "linkedServices")
                            self.defaults.synchronize()
                            self.runKeeperStatusLabel.text = "Connect"
                        }
                    })
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    rk.authorizeEmbeddedFrom(self, params: nil, afterAuthorizeOrFailure: {wasFailure, error in
                        if !wasFailure {
                            func linkService(linkedServices: [String], serviceName: String) {
                                if !contains(linkedServices, serviceName) {
                                    var linkedServices = linkedServices
                                    linkedServices.append(serviceName)
                                    self.linkedServices = linkedServices
                                    self.defaults.setObject(linkedServices, forKey: "linkedServices")
                                    self.defaults.synchronize()
                                }
                            }

                            self.defaults.arrayForKey("linkedServices")
                            if let linkedServices = self.defaults.arrayForKey("linkedServices") as? [String] {
                                linkService(linkedServices, "RunKeeper")
                            } else {
                                linkService([String](), "RunKeeper")
                            }
                            self.runKeeperStatusLabel.text = "Linked"
                        }
                    })
                }
            }
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
