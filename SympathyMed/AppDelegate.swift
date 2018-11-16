//
//  AppDelegate.swift
//  SympathyMed
//
//  Created by Vasiliy Egorov on 10.04.2018.
//  Copyright © 2018 SympathyMed. All rights reserved.
//

import UIKit
import GoogleMaps

let mapsKey = "AIzaSyCQ1s__-bKV4NQAOWYVrBaN5dcCGROATZs"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let stateChecker = StateChecker()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey(mapsKey)
        self.stateChecker.saveState(isAnimationAllowed: true)
        
        let device = Device.init(rawValue: UIScreen.main.bounds.height)
        
        switch device {
            case .Iphone5?,.Iphone6_7?,.Iphone6_7_plus?,.IphoneX?:
                setStoryboard(name: "MainIPhone", controllerIdentifier: "MainMenuViewController")
            case .IpadMini_Air?,.IpadPro10_5?,.IpadPro12_9?:
                setStoryboard(name: "MainIPad", controllerIdentifier: "MainMenuViewController")
        default: break
        }

        return true
    }
    
    
    func setStoryboard(name: String, controllerIdentifier: String) {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: name, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: controllerIdentifier)
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        
        if let rootViewController = self.topViewControllerWithRootViewController(rootViewController: window?.rootViewController) {
            
            if rootViewController is TextDetectionViewController {
                return .landscapeRight
            }
        }
        
        return .portrait
    }
    
    
    private func topViewControllerWithRootViewController(rootViewController: UIViewController?) -> UIViewController? {
        if rootViewController == nil { return nil }
        if rootViewController is UITabBarController {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
        } else if rootViewController is UINavigationController {
            return topViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
        } else if rootViewController?.presentedViewController != nil {
            return topViewControllerWithRootViewController(rootViewController: rootViewController?.presentedViewController!)
        }
        return rootViewController
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.stateChecker.saveState(isAnimationAllowed: true)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        self.stateChecker.saveState(isAnimationAllowed: false)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.stateChecker.saveState(isAnimationAllowed: true)
    }


}

