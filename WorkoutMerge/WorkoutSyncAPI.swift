//
//  WorkoutSyncAPI.swift
//  WorkoutMerge
//
//  Created by Jason Kusnier on 7/31/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import UIKit
import HealthKit

protocol WorkoutSyncAPI {
    
    func authorizeEmbeddedFrom(controller: UIViewController, params: [String : String]?, afterAuthorizeOrFailure: (wasFailure: Bool, error: NSError?) -> Void)
    
    func disconnect()
    
//    class func handleRedirectURL(url: NSURL)
    
    func postActivity(workout: (UUID: NSUUID?, type: String?, startTime: NSDate?, totalDistance: Double?, duration: Double?, averageHeartRate: Int?, totalCalories: Double?, notes: String?, otherType: String?), failure fail : ((NSError?, String) -> ())?, success succeed: ((savedKey: String?) -> ())?)
    
    static func activityType(t: HKWorkoutActivityType) -> String
    
    static func otherActivityType(t: HKWorkoutActivityType) -> String?
}