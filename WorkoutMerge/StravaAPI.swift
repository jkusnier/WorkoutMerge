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
    let baseURL = NSURL(string: "https://www.strava.com")!
    
    override init() {
        var settings = [
            "authorize_uri": "https://www.strava.com/oauth/authorize",
            "token_uri": "https://www.strava.com/oauth/token",
            "redirect_uris": ["http://www.workoutmerge.com/callback"],
            "secret_in_body": true,
            "verbose": true,
            "scope": "write",
            ] as OAuth2JSON
        
        var myDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("ApiKeys", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            if let strava = dict["strava"] as? NSDictionary {
                settings["client_id"] = strava["client_id"]
                settings["client_secret"] = strava["client_secret"]
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
        
        super.init(activityTypes: [
            "Ride",
            "Run",
            "Swim",
            "Workout",
            "Hike",
            "Walk"
            ], otherTypes: [String]())
    }
    
    override func authorizeEmbeddedFrom(controller: UIViewController, params: [String : String]?, afterAuthorizeOrFailure: (wasFailure: Bool, error: NSError?) -> Void) {
        let web = self.oauth2.authorizeEmbeddedFrom(controller, params: params)
        
        self.oauth2.afterAuthorizeOrFailure = { wasFailure, error in
            if !wasFailure {
                web.dismissViewControllerAnimated(true, completion: nil)
            }
            afterAuthorizeOrFailure(wasFailure: wasFailure, error: error)
        }
    }
    
    override func disconnect() {
        self.oauth2.forgetTokens()
    }
    
    override class func handleRedirectURL(url: NSURL) {
        sharedInstance.oauth2.handleRedirectURL(url)
    }
    
    override func postActivity(workout: (UUID: NSUUID?, type: String?, startTime: NSDate?, totalDistance: Double?, duration: Double?, averageHeartRate: Int?, totalCalories: Double?, notes: String?, otherType: String?, activityName: String?), failure fail : ((NSError?, String) -> ())? = { error in println(error) }, success succeed: ((savedKey: String?) -> ())? = nil) {
        let path = "api/v3/activities"
        let url = baseURL.URLByAppendingPathComponent(path)
        let req = oauth2.request(forURL: url)
        
        var jsonData = [String]()
        
        if let type = workout.type {
            jsonData.append("\"type\":\"\(type)\"")
        }
        if let startTime = workout.startTime {
            let startTimeString = startTime.ISOStringFromDate()
            jsonData.append("\"start_date_local\":\"\(startTimeString)\"")
        }
        if let duration = workout.duration {
            jsonData.append("\"elapsed_time\":\(Int(duration))")
        }
        if let totalDistance = workout.totalDistance {
            jsonData.append("\"distance\":\(totalDistance)")
        }
        if let activityName = workout.activityName {
            jsonData.append("\"name\":\"\(activityName)\"")
        } else {
            if let type = workout.type, startTime = workout.startTime {
                jsonData.append("\"name\":\"\(startTime.dayOfWeek()) - \(type)\"")
            } else {
                jsonData.append("\"name\":\"unknown\"")
            }
        }

        // Strava doesn't accept heart rate or calories
//        if let averageHeartRate = workout.averageHeartRate {
//            jsonData.append("\"average_heart_rate\":\(averageHeartRate)")
//        }
//        if let totalCalories = workout.totalCalories {
//            jsonData.append("\"total_calories\":\(totalCalories)")
//        }
        if let notes = workout.notes {
            jsonData.append("\"description\":\"\(notes)\"")
        }
//        if let type = workout.type, otherType = workout.otherType where type == "Other" {
//            jsonData.append("\"secondary_type\":\"\(otherType)\"")
//        }
        
        var joiner = ","
        var jsonString = "{" + joiner.join(jsonData) + "}"
        
        req.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        req.HTTPMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(req) { data, response, error in
            
            if let httpResponse = response as? NSHTTPURLResponse {
                if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                    println("success")

                    var savedKey: String?
                    var error: NSError?
                    if let jsonDict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? NSDictionary {
                        if let workoutId = jsonDict["id"] as? Int {
                            savedKey = "\(workoutId)"
                        }
                    }
                    succeed!(savedKey: savedKey)
                } else {
                    println("failure")
                    if let fail = fail {
                        if let error = error {
                            fail(error, "Status Code \(httpResponse.statusCode)")
                        }
                    }
                }
            } else {
                println("fail")
                if let fail = fail {
                    fail(error, "No Response")
                }
            }
        }
        task.resume()

        //[
        //    name:	string required
        //    type:	string required, case insensitive
        //    start_date_local:	datetime required ISO 8601 formatted date time, see Dates for more information
        //    elapsed_time:	integer required seconds
        //    description:	string optional
        //    distance:	float optional meters
        //    private:	integer optional 1 is private
        //    trainer:	integer optional 1 is trainer
        //    commute:	integer optional  1 is commute
        //]
    }
    
    override func activityType(t: HKWorkoutActivityType) -> String {
        switch t {
        case .Cycling: return "Ride"
        case .Running: return "Run"
        case .Swimming: return "Swim"
        case .CrossTraining: return "Workout"
        case .Hiking: return "Hike"
        case .Walking: return "Walk"
        default: return "Ride"
        }
        
        // nordicski, alpineski, backcountryski, iceskate, inlineskate, kitesurf, rollerski, windsurf, workout, snowboard, snowshoe, ebikeride, virtualride
    }
    
    override func otherActivityType(t: HKWorkoutActivityType) -> String? {
        switch t {
        default: return nil
        }
    }
}