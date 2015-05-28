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
}