//
//  RunKeeperAPI.swift
//  HealthLink
//
//  Created by Jason Kusnier on 5/27/15.
//  Copyright (c) 2015 Jason Kusnier. All rights reserved.
//

import Foundation
import p2_OAuth2

class RunKeeperAPI {
    static let sharedInstance = RunKeeperAPI()
    
    let oauth2:OAuth2CodeGrant
    let baseURL = NSURL(string: "https://api.runkeeper.com")!
    
    init() {
        var settings = [
            "authorize_uri": "https://runkeeper.com/apps/authorize",
            "token_uri": "https://runkeeper.com/apps/token",
            "redirect_uris": ["healthlink://oauth.runkeeper/callback"],
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
    
    func authorize() {
        self.oauth2.authorize()
    }
    
    class func handleRedirectURL(url: NSURL) {
        sharedInstance.oauth2.handleRedirectURL(url)
    }
    
    func postActivity(callback: ((dict: NSDictionary?, error: NSError?) -> Void)) {
        let path = "/fitnessActivities"
        let url = baseURL.URLByAppendingPathComponent(path)
        let req = oauth2.request(forURL: url)
//        req.setValue("application/vnd.com.runkeeper.NewFitnessActivity+json", forHTTPHeaderField: "Accept")
        
        let jsonString = "{\"type\": \"Running\",\"equipment\": \"None\",\"start_time\": \"Thu, 28 May 2015 21:00:00\",\"duration\": 80,\"notes\": \"Test WorkoutMerge\"}"
        req.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        req.HTTPMethod = "POST"
        req.setValue("application/vnd.com.runkeeper.NewFitnessActivity+json", forHTTPHeaderField: "Content-Type")
        
        let queue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(req, queue: queue, completionHandler: { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                
                if let httpResponse = response as? NSHTTPURLResponse {
                    if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                        println("success")
                    } else {
                        println("failure")
                    }
                } else {
                    println("fail")
                }
            })
        })
    }
}