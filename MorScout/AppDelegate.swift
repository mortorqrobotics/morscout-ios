//
//  AppDelegate.swift
//  MorScout
//
//  Created by Farbod Rafezy on 1/8/16.
//  Copyright © 2016 MorTorq. All rights reserved.
//

import UIKit
import Kingfisher

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func logoutSilently() {
        httpRequest(morTeamURL+"/f/logout", type: "POST"){ responseText in
            for key in storage.dictionaryRepresentation().keys {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(key)
            }
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
//        print("INITIAL MATCH DATA:")
//        print(MatchDataStorage.sharedInstance.data)
        
        UINavigationBar.appearance().barTintColor = UIColorFromHex("#FFC547")
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        UINavigationBar.appearance().translucent = false
        
        
        KingfisherManager.sharedManager.downloader.requestModifier = {
            (request: NSMutableURLRequest) in
            
            request.addValue("connect.sid=\(storage.stringForKey("connect.sid")!)", forHTTPHeaderField: "Cookie")
        }
        
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let revealVC : UIViewController! = mainStoryboard.instantiateViewControllerWithIdentifier("reveal")
        let loginVC : UIViewController! = mainStoryboard.instantiateViewControllerWithIdentifier("login")
        
        
        if let _ = storage.stringForKey("connect.sid"){
            //logged in
            if storage.boolForKey("noTeam") {
                logoutSilently()
                self.window?.rootViewController = loginVC
            }else{
                self.window?.rootViewController = revealVC
            }
        }else{
            //logged out
            self.window?.rootViewController = loginVC
        }

        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

