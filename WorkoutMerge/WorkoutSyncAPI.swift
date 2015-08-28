//
//  WorkoutSyncAPI.swift
//  WorkoutMerge
//
//  Created by Jason Kusnier on 7/31/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import UIKit
import HealthKit

class WorkoutSyncAPI {
    
    let activityTypes: [String]
    let otherTypes: [String]
    
    init() {
        self.activityTypes = [String]()
        self.otherTypes = [String]()
    }
    
    init(activityTypes: [String], otherTypes: [String]) {
        self.activityTypes = activityTypes
        self.otherTypes = otherTypes
    }
    
    func authorizeEmbeddedFrom(controller: UIViewController, params: [String : String]?, afterAuthorizeOrFailure: (wasFailure: Bool, error: NSError?) -> Void) {
    }
    
    func disconnect() {
    }
    
    class func handleRedirectURL(url: NSURL) {
    }
    
    func postActivity(workout: (UUID: NSUUID?, type: String?, startTime: NSDate?, totalDistance: Double?, duration: Double?, averageHeartRate: Int?, totalCalories: Double?, notes: String?, otherType: String?, activityName: String?), failure fail : ((NSError?, String) -> ())?, success succeed: ((savedKey: String?) -> ())?, controller: UIViewController?, params: [String : String]?) {
    }
    
    func activityType(t: HKWorkoutActivityType) -> String {
        switch t {
        case .Running: return "Running"
        case .Cycling: return "Cycling"
            //      Mountain Biking
        case .Walking: return "Walking"
        case .Hiking: return "Hiking"
            //      Downhill Skiing
            //      Cross-Country Skiing
            //      Snowboarding
            //      Skating
        case .Swimming: return "Swimming"
            //      Wheelchair
        case .Rowing: return "Rowing"
        case .Elliptical: return "Elliptical"
        default: return "Other"
        }
    }
    
    func otherActivityType(t: HKWorkoutActivityType) -> String? {
        return nil
    }
}