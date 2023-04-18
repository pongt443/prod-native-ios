//
//  AppDelegate.swift
//  native_ios_new1
//
//  Created by Tanakorn Chauekid on 10/4/2566 BE.
//

import UIKit
import Flutter
import GoogleMaps
// The following library connects plugins with iOS platform code to this app.
import FlutterPluginRegistrant
@UIApplicationMain
class AppDelegate: FlutterAppDelegate { // More on the FlutterAppDelegate.
  lazy var flutterEngine = FlutterEngine(name: "flutter_engine")
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      GMSServices.provideAPIKey("AIzaSyBriR3_kCzOfST0t72bMUV1B3-p2fnJ_dw")
    // Runs the default Dart entrypoint with a default Flutter route.
    flutterEngine.run();
    // Connects plugins with iOS platform code to this app.
    GeneratedPluginRegistrant.register(with: self.flutterEngine);
    return super.application(application, didFinishLaunchingWithOptions: launchOptions);
  }


//@main
//class AppDelegate: UIResponder, UIApplicationDelegate {
//
//
//
////    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
////        // Override point for customization after application launch.
////        return true
////    }

    // MARK: UISceneSession Lifecycle

    override func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    override func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


    //LN Caller
    /*
     
     
     import Flutter
     //import GoogleMaps
     // The following library connects plugins with iOS platform code to this app.
     import FlutterPluginRegistrant
     @UIApplicationMain
     class AppDelegate: FlutterAppDelegate { // More on the FlutterAppDelegate.
       lazy var flutterEngine = FlutterEngine(name: "flutter_engine")
       override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
           //GMSServices.provideAPIKey("AIzaSyBriR3_kCzOfST0t72bMUV1B3-p2fnJ_dw")
         // Runs the default Dart entrypoint with a default Flutter route.
         flutterEngine.run();
         // Connects plugins with iOS platform code to this app.
         GeneratedPluginRegistrant.register(with: self.flutterEngine);
         return super.application(application, didFinishLaunchingWithOptions: launchOptions);
       }
     }
     
     
     
     */
}

