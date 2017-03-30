//
//  AppDelegate.swift
//  PopUpDeal
//
//  Created by Suraj MAC2 on 2/20/16.
//  Copyright © 2016 supaint. All rights reserved.
//

import UIKit

import CoreLocation
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate {

    var window: UIWindow?
    var baseUrl : String = String()
    var requestHeaders = ["Content-Type":"application/json" ]
    let userPlaceHolderImage : UIImage = UIImage(named: "profile_temp.jpg")!
    let businessPlaceHolderImage : UIImage = UIImage(named: "placeholder-rect.jpg")!
    let businessPlaceHolderImagesquare : UIImage = UIImage(named: "placeholder-square.jpg")!
    
    let imageCache : NSCache = NSCache()
    var screenWidth : CGFloat = CGFloat()
    var screenHeight : CGFloat = CGFloat()
    var deviceTokenToSend : String = String()
    var deviceUDID : String = String()
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation!
    var currentLat : String = String()
    var currentLong : String = String()
    var locationStatusEnable : Bool = Bool()
    
    
    var locFlag : Bool!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        deviceUDID  = UIDevice.currentDevice().identifierForVendor!.UUIDString
        
        currentLat = "0"
        currentLong = "0"
        //Get screen size
        screenWidth = UIScreen.mainScreen().bounds.width
        screenHeight = UIScreen.mainScreen().bounds.height
        
       // baseUrl = "http:/www.supraint.com/works/buzz-deal/mobwebservice/ios/"
        baseUrl = "http://www.buzzdeal.net/mobwebservice/ios/"
       
        //Fabric Setup
        Fabric.with([Crashlytics.self])

        
        
        //Mannually override IQKeyboardManager
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
      
        //Google Map API Key, USed xtestonline@gmail.com account for developmenet key
       // GMSServices.provideAPIKey("AIzaSyCocdWhUYzQ_P34eTth8moiPK-asLIxf7U")
        
        //Remote Notification Code 
        self.initializeNotificationSetting()
        
        //Facebook init
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    
    
//TODO: - Facebook Methods
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    
//TODO: - Remote Notification Initialization
    
    func initializeNotificationSetting(){
        //Remote Notification Code
        let setting = UIUserNotificationSettings(forTypes: [.Sound,.Badge,.Alert], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(setting)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
//TODO: - Remote Notification Delegate Method
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        let deviceTokenString: String = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        print(" deviceTokenString : \(deviceTokenString)" )
        deviceTokenToSend = deviceTokenString
        NSNotificationCenter.defaultCenter().postNotificationName("GotDeviceToken", object: nil)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error.localizedDescription)
    }
    
//TODO: - Call this method when notification is received
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        print("notification data is : \(userInfo)")
        
    }
    
    
    
    func displayMessage(titleString : String, messageText : String){
        let alert = UIAlertController(title: titleString, message: messageText, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        
        self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
    }

//TODO: ShareOnWhatsApp
    
    func ShareOnWhatsApp(urlString : String){
        
        let msg = urlString
        let urlWhats = "whatsapp://send?text=\(msg)"
        if let urlString = urlWhats.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
            
            if let whatsappURL = NSURL(string: urlString) {
                if UIApplication.sharedApplication().canOpenURL(whatsappURL) {
                    UIApplication.sharedApplication().openURL(whatsappURL)
                } else {
                    let alertController = UIAlertController(title: "BuzzDeal", message: "Whatsapp is not install on your device", preferredStyle: .Alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.window?.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func initiateCallToBusiness(urlString : String){
        
        let urlStringEncoded = urlString.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())
        
        //URLHostAllowedCharacterSet
        let urlToGo  = NSURL(string: "tel://\(urlStringEncoded!)")
        print(urlToGo)
        
        if UIApplication.sharedApplication().canOpenURL(urlToGo!){
            UIApplication.sharedApplication().openURL(urlToGo!)
        }else{
            let alertController = UIAlertController(title: "BuzzDeal", message: "Your device does not support dialer", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertController.addAction(defaultAction)
            self.window?.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
        }
        
        
    }

    
    //Design functions
    
    func buttonGradientColor(testView:CGRect) {
        let gradientColor : CAGradientLayer = CAGradientLayer()
        gradientColor.frame = testView
        
        gradientColor.startPoint = CGPointMake(0.7, 0)
        gradientColor.endPoint = CGPointMake(0, 0.7)
        
        // gradientColor.startPoint = CGPointMake(0.5, 0.9)
        //gradientColor.endPoint = CGPointMake(0, 0.5)
        gradientColor.colors = [UIColor(red: 251/255, green: 251/255, blue: 251/255, alpha: 1.0).CGColor,UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1.0).CGColor]
        
    }
    
//TODO: Location function
    
    func CurrentLocationIdentifier(){
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
        locFlag = false
        let status = CLLocationManager.authorizationStatus()
        locationStatusEnable = true
        /*if(status == .Denied || status == .AuthorizedWhenInUse){
            
            var title: String
            title =  "Location services are off Background location is not enabled"
            let message: String = "To use background location you must turn on 'Always' in the Location Services Settings"
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
          
            let defaultAction = UIAlertAction(title: "Setting", style: .Default, handler: { (value:UIAlertAction) in
                let settingsURL: NSURL = NSURL(string: UIApplicationOpenSettingsURLString)!
                if(UIApplication.sharedApplication().canOpenURL(settingsURL)){
                    UIApplication.sharedApplication().openURL(settingsURL)
                }else{
                    print("Unable to open URL")
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            alertController.addAction(cancelAction)
            self.window?.rootViewController!.presentViewController(alertController, animated: true, completion: nil)
            
        }*/
        if status == .NotDetermined || status == .Denied {
            // present an alert indicating location authorization required
            // and offer to take the user to Settings for the app via
            // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
            locationStatusEnable = false
            locationManager.requestWhenInUseAuthorization()
           // NSNotificationCenter.defaultCenter().postNotificationName("postLocationUpdate", object: nil)
           // locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        print(error)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(!locFlag){
            locFlag = true
       
            let locationArray = locations as NSArray
            currentLocation = locationArray.lastObject as! CLLocation
            let coord = currentLocation.coordinate
            //locationManager.stopUpdatingLocation()
            NSNotificationCenter.defaultCenter().postNotificationName("postLocationUpdate", object: nil)
            currentLat = "\(coord.latitude)"
            currentLong = "\(coord.longitude)"
           
            NSUserDefaults.standardUserDefaults().setValue(coord.latitude, forKey: "currentLat")
            NSUserDefaults.standardUserDefaults().setValue(coord.longitude, forKey: "currentLon")
            //  currentLat = String(format:"%.1f", coord.latitude)
            //currentLong = String(format:"%.1f", coord.longitude)
            
            print(coord.latitude)
            print(coord.longitude)
         }
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
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

