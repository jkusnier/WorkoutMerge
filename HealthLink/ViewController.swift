//
//  ViewController.swift
//  HealthLink
//
//  Created by Jason Kusnier on 5/23/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController {
    
    let hkStore = HKHealthStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let readTypes = Set([
            HKObjectType.workoutType()
        ])
        
        if !HKHealthStore.isHealthDataAvailable() {
            println("HealthKit Not Available")
        } else {
        
            hkStore.requestAuthorizationToShareTypes(nil, readTypes: readTypes, completion: { (success: Bool, err: NSError!) -> () in
                println("okay: \(success) error: \(err)")
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

