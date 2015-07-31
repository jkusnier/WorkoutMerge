//
//  StravaAPI.swift
//  WorkoutMerge
//
//  Created by Jason Kusnier on 7/28/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import UIKit
import p2_OAuth2
import HealthKit

class StravaAPI: WorkoutSyncAPI {
    static let sharedInstance = StravaAPI()
    
    let oauth2:OAuth2CodeGrant
    let baseURL = NSURL(string: "https://www.strava.com/api")!
    
    init() {
        var settings = [
            "authorize_uri": "https://www.strava.com/oauth/authorize",
            "token_uri": "https://www.strava.com/oauth/token",
            "redirect_uris": ["http://www.workoutmerge.com/callback"],
            "secret_in_body": true,
            "verbose": true,
            ] as OAuth2JSON
        
        var myDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("ApiKeys", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            if let strava = dict["strava"] as? NSDictionary {
                settings["client_id"] = strava["client_id"]
                settings["client_secret"] = strava["client_secret"]
                settings["access_token"] = strava["access_token"]
            }
        }
        
        self.oauth2 = OAuth2CodeGrant(settings: settings)
        self.oauth2.viewTitle = "Strava"
        self.oauth2.onAuthorize = { parameters in
            println("Did authorize with parameters: \(parameters)")
        }
        self.oauth2.onFailure = { error in
            if nil != error {
                println("Authorization went wrong: \(error!.localizedDescription)")
            }
        }
    }
    
    func authorizeEmbeddedFrom(controller: UIViewController, params: [String : String]?, afterAuthorizeOrFailure: (wasFailure: Bool, error: NSError?) -> Void) {
        let web = self.oauth2.authorizeEmbeddedFrom(controller, params: params)
        
        self.oauth2.afterAuthorizeOrFailure = { wasFailure, error in
            if !wasFailure {
                web.dismissViewControllerAnimated(true, completion: nil)
            }
            afterAuthorizeOrFailure(wasFailure: wasFailure, error: error)
        }
    }
    
    func disconnect() {
        self.oauth2.forgetTokens()
    }
    
    class func handleRedirectURL(url: NSURL) {
        sharedInstance.oauth2.handleRedirectURL(url)
    }
    
    func postActivity(workout: (UUID: NSUUID?, type: String?, startTime: NSDate?, totalDistance: Double?, duration: Double?, averageHeartRate: Int?, totalCalories: Double?, notes: String?, otherType: String?), failure fail : ((NSError?, String) -> ())? = { error in println(error) }, success succeed: ((savedKey: String?) -> ())? = nil) {
    }
    
    static func activityType(t: HKWorkoutActivityType) -> String {
        switch t {
        default: return "Other"
        }
    }
    
    static func otherActivityType(t: HKWorkoutActivityType) -> String? {
        switch t {
        default: return nil
        }
    }
}