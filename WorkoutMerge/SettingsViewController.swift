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
import CoreData

class SettingsViewController: UITableViewController {
    
    let hkStore = HKHealthStore()
    let defaults = NSUserDefaults.standardUserDefaults()
    var linkedServices: [String]?

    @IBOutlet weak var runKeeperStatusLabel: UILabel!
    @IBOutlet weak var stravaStatusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let linkedServices = self.defaults.arrayForKey("linkedServices") as? [String] {
            self.linkedServices = linkedServices
            
            if contains(linkedServices, "RunKeeper") {
                self.runKeeperStatusLabel.text = "Linked"
            } else {
                self.runKeeperStatusLabel.text = "Connect"
            }
            
            if contains(linkedServices, "Strava") {
                self.stravaStatusLabel.text = "Linked"
            } else {
                self.stravaStatusLabel.text = "Connect"
            }
        }
        
        self.tableView.contentInset = UIEdgeInsetsMake(20, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
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
        } else if indexPath.section == 0 && indexPath.row == 2 {
            println("Strava")
            
            if self.linkedServices == nil {
                self.linkedServices = [String]()
            }
            
            if let linkedServices = self.linkedServices {
                let strava = StravaAPI.sharedInstance
                
                if contains(linkedServices, "Strava") {
                    let alertController = UIAlertController(title: "Alert", message: "Are you sure you want to unlink Strava?", preferredStyle: .Alert)
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: .Default) { (action) in
                        let dataRemoveAlertController = UIAlertController(title: "Remove Strava Data?", message: "Pressing YES will remove any linking data between WorkoutMerge and Strava.", preferredStyle: .Alert)
                        
                        // This way eliminates the "cannot reference a local function with captures from another local function" error.
                        let disconnect:() -> () = {
                            strava.disconnect()
                            if let i = find(linkedServices, "Strava") {
                                self.linkedServices?.removeAtIndex(i)
                                self.defaults.setObject(self.linkedServices, forKey: "linkedServices")
                                self.defaults.synchronize()
                                self.stravaStatusLabel.text = "Connect"
                            }
                        }
                        
                        dataRemoveAlertController.addAction(UIAlertAction(title: "YES", style: .Default) { (action) in
                            // Remove Strava core data fields
                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                            let managedContext = appDelegate.managedObjectContext!
                            
                            let fetchRequest = NSFetchRequest(entityName: "SyncLog")
                            let predicate = NSPredicate(format: "syncToStrava != nil")
                            fetchRequest.predicate = predicate
                            
                            if let fetchedEntities = managedContext.executeFetchRequest(fetchRequest, error: nil) {
                                for fetchedEntity in fetchedEntities {
                                    if let fetchedEntity = fetchedEntity as? NSManagedObject {
                                        fetchedEntity.setValue(nil, forKeyPath: "syncToStrava")
                                        fetchedEntity.setValue(nil, forKeyPath: "savedKeyStrava")
                                    }
                                }
                                
                                var error: NSError?
                                if !managedContext.save(&error) {
                                    println("Could not save \(error)")
                                }
                            }
                            
                            disconnect()
                        })
                        
                        dataRemoveAlertController.addAction(UIAlertAction(title: "No", style: .Cancel) { (action) in
                            disconnect()
                        })
                        self.presentViewController(dataRemoveAlertController, animated: true, completion: nil)
                    })
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                } else {
                    strava.authorizeEmbeddedFrom(self, params: nil, afterAuthorizeOrFailure: {wasFailure, error in
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
                                linkService(linkedServices, "Strava")
                            } else {
                                linkService([String](), "Strava")
                            }
                            self.stravaStatusLabel.text = "Linked"
                        }
                    })
                }
            }
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
