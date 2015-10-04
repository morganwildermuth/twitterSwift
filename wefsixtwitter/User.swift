//
//  User.swift
//  wefsixtwitter
//
//  Created by Morgan Wildermuth on 10/4/15.
//  Copyright © 2015 WEF6. All rights reserved.
//

import UIKit

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    
    var name: String?
    var screenname: String?
    var profileImageUrl: String?
    var tagLine: String?
    var dictionary = NSDictionary()

    init(dictionary: NSDictionary){
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        profileImageUrl = dictionary["profile_image_url"] as? String
        tagLine = dictionary["description"] as? String
    }
    
    func logout(){
        // this will also clear in standard user default due to currentUser set method
        User.currentUser = nil
        
        // remove all permissions
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        //NSNotifications, great system to send broadcasts
        // in large apps, many view controller might care about global actions like sign out
        // defaultCenter same as our Singleton pattern of Twitter.sharedInstance()
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
        
    }
    
    //object in data, but nsuserdefaults should have user info
    
    // global notion of current user at any time
    //NSCoding describes how to serialize and deserialize objects, but JSON is serialized by default, which is why the initial dictionary was kept around; a bit of a cheat
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                var data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
        
                if data != nil {
                    do {
                        var dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0))
                        _currentUser = User(dictionary: dictionary as! NSDictionary)
                    } catch {
                        print("deserialization of user data errored")
                    }
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            
            if _currentUser != nil {
                do {
                    var data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: NSJSONWritingOptions(rawValue: 0))
                     NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
                } catch {
                    print("serialization of user data errored")
                }
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

}
