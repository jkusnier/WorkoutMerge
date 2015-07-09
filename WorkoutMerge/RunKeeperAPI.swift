//
//  RunKeeperAPI.swift
//  WorkoutMerge
//
//  Created by Jason Kusnier on 5/27/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import Foundation
import p2_OAuth2
import HealthKit

class RunKeeperAPI {
    static let sharedInstance = RunKeeperAPI()
    
    let oauth2:OAuth2CodeGrant
    let baseURL = NSURL(string: "https://api.runkeeper.com")!
    
    static let activityTypes = ["Cycling", "Elliptical", "Hiking", "Rowing", "Running", "Swimming", "Walking", "Other"]
    
    init() {
        var settings = [
            "authorize_uri": "https://runkeeper.com/apps/authorize",
            "token_uri": "https://runkeeper.com/apps/token",
            "redirect_uris": ["workoutmerge://oauth.runkeeper/callback"],
            "secret_in_body": true,
            "verbose": true,
        ] as OAuth2JSON
        
        var myDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("ApiKeys", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = myDict {
            if let runKeeper = dict["runKeeper"] as? NSDictionary {
                settings["client_id"] = runKeeper["client_id"]
                settings["client_secret"] = runKeeper["client_secret"]
            }
        }
                
        self.oauth2 = OAuth2CodeGrant(settings: settings)
        self.oauth2.viewTitle = "RunKeeper"
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
            web.dismissViewControllerAnimated(true, completion: nil)
            afterAuthorizeOrFailure(wasFailure: wasFailure, error: error)
        }

    }
    
    func disconnect() {
        self.oauth2.forgetTokens()
    }
    
    class func handleRedirectURL(url: NSURL) {
        sharedInstance.oauth2.handleRedirectURL(url)
    }
    
    func postActivity(workout: (UUID: NSUUID?, type: String?, startTime: NSDate?, totalDistance: Double?, duration: Double?, averageHeartRate: Int?, totalCalories: Double?, notes: String?), failure fail : (NSError? -> ())? = { error in println(error) }, success succeed: ((savedKey: String?) -> ())? = nil) {
        let path = "/fitnessActivities"
        let url = baseURL.URLByAppendingPathComponent(path)
        let req = oauth2.request(forURL: url)
        
        var jsonData = [String]()
        if let type = workout.type {
            jsonData.append("\"type\":\"\(type)\"")
        }
        if let startTime = workout.startTime {
            let dateFormatter = NSDateFormatter()
            // Sat, 1 Jan 2011 00:00:00
            dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss"
            let startTimeString = dateFormatter.stringFromDate(startTime)
            
            jsonData.append("\"start_time\":\"\(startTimeString)\"")
        }
        if let totalDistance = workout.totalDistance {
            jsonData.append("\"total_distance\":\(totalDistance)")
        }
        if let duration = workout.duration {
            jsonData.append("\"duration\":\(duration)")
        }
        if let averageHeartRate = workout.averageHeartRate {
            jsonData.append("\"average_heart_rate\":\(averageHeartRate)")
        }
        if let totalCalories = workout.totalCalories {
            jsonData.append("\"total_calories\":\(totalCalories)")
        }
        if let notes = workout.notes {
            jsonData.append("\"notes\":\"\(notes)\"")
        }
        
        var joiner = ","
        var jsonString = "{" + joiner.join(jsonData) + "}"
        
        req.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        req.HTTPMethod = "POST"
        req.setValue("application/vnd.com.runkeeper.NewFitnessActivity+json", forHTTPHeaderField: "Content-Type")
        
        let queue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(req, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                
                if let httpResponse = response as? NSHTTPURLResponse {
                    if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                        println("success")
                        let allHeaders = httpResponse.allHeaderFields
                        var savedKey: String?
                        if let location = allHeaders["Location"] as? String {
                            savedKey = location
                        }
                        succeed!(savedKey: savedKey)
                    } else {
                        println("failure")
                        if let fail = fail {
                            fail(error)
                        }
                    }
                } else {
                    println("fail")
                    if let fail = fail {
                        fail(error)
                    }
                }
            })
        })
    }
    
    static func activityType(t: HKWorkoutActivityType) -> String {
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
    
    static func otherActivityType(t: HKWorkoutActivityType) -> String? {
        switch t {
        case .AmericanFootball: return "AmericanFootball"
        case .Archery: return "Archery"
        case .AustralianFootball: return "AustralianFootball"
        case .Badminton: return "Badminton"
        case .Baseball: return "Baseball"
        case .Basketball: return "Basketball"
        case .Bowling: return "Bowling"
        case .Boxing: return "Boxing"
        case .Climbing: return "Climbing"
        case .Cricket: return "Cricket"
        case .CrossTraining: return "CrossTraining"
        case .Curling: return "Curling"
//        case .Cycling: return "Cycling"
        case .Dance: return "Dance"
        case .DanceInspiredTraining: return "DanceInspiredTraining"
//        case .Elliptical: return "Elliptical"
        case .EquestrianSports: return "EquestrianSports"
        case .Fencing: return "Fencing"
        case .Fishing: return "Fishing"
        case .FunctionalStrengthTraining: return "FunctionalStrengthTraining"
        case .Golf: return "Golf"
        case .Gymnastics: return "Gymnastics"
        case .Handball: return "Handball"
//        case .Hiking: return "Hiking"
        case .Hockey: return "Hockey"
        case .Hunting: return "Hunting"
        case .Lacrosse: return "Lacrosse"
        case .MartialArts: return "MartialArts"
        case .MindAndBody: return "MindAndBody"
        case .MixedMetabolicCardioTraining: return "MixedMetabolicCardioTraining"
        case .PaddleSports: return "PaddleSports"
        case .Play: return "Play"
        case .PreparationAndRecovery: return "PreparationAndRecovery"
        case .Racquetball: return "Racquetball"
//        case .Rowing: return "Rowing"
        case .Rugby: return "Rugby"
//        case .Running: return "Running"
        case .Sailing: return "Sailing"
        case .SkatingSports: return "SkatingSports"
        case .SnowSports: return "SnowSports"
        case .Soccer: return "Soccer"
        case .Softball: return "Softball"
        case .Squash: return "Squash"
        case .StairClimbing: return "StairClimbing"
        case .SurfingSports: return "SurfingSports"
//        case .Swimming: return "Swimming"
        case .TableTennis: return "TableTennis"
        case .Tennis: return "Tennis"
        case .TrackAndField: return "TrackAndField"
        case .TraditionalStrengthTraining: return "TraditionalStrengthTraining"
        case .Volleyball: return "Volleyball"
//        case .Walking: return "Walking"
        case .WaterFitness: return "WaterFitness"
        case .WaterPolo: return "WaterPolo"
        case .WaterSports: return "WaterSports"
        case .Wrestling: return "Wrestling"
        case .Yoga: return "Yoga"
        default: return nil
        }
    }
}