//
//  SettingsViewController.swift
//  HealthLink
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

    @IBOutlet weak var runKeeperStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            
            let rk = RunKeeperAPI.sharedInstance
            rk.authorize({wasFailure, error in
                if !wasFailure {
                    func linkService(linkedServices: [String], serviceName: String) {
                        if !contains(linkedServices, serviceName) {
                            var linkedServices = linkedServices
                            linkedServices.append(serviceName)
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
                }
            })
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
