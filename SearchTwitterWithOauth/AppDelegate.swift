//
//  AppDelegate.swift
//  SearchTwitterWithOauth
//
//  Created by Larry on 16/5/14.
//  Copyright © 2016年 Larry. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    
    //MARK: -Location
    
    let locationManager = CLLocationManager()

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.NotDetermined || status == CLAuthorizationStatus.Denied || status == CLAuthorizationStatus.Restricted {
            locationManager.startUpdatingLocation()
            locationManager.requestWhenInUseAuthorization() //当app进入前台的时候再开启定位
        }
    }
    
    func configLocation(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 50
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last {
            let currentLongtitude = Float(newLocation.coordinate.longitude)
            let currentLatitude = Float(newLocation.coordinate.latitude)
            
            longitude = String(format: "%.6f", currentLongtitude)
            latitude = String(format: "%.6f", currentLatitude)

            locationManager.stopUpdatingLocation()
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("locationManager didFailWithError:\(error)")
        
        longitude = ""
        latitude  = ""
    }
    
    
    //MARK: - Application life cycle
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        configLocation()
        
        Tools.getCountryCodes({ (code) in
                guard let newCountryCodes = code else{
                    return
                }
                language = newCountryCodes
            
            }, failure: nil)
        
        Tools.getTwitterOauth({ (header) in
                guard let newQueryHeader = header as? String else{
                    return
                }
                queryHeader = newQueryHeader
            }, failure: nil)
        
        Constants.setUserDefaults()
        
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

