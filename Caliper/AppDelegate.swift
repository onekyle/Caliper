//
//  AppDelegate.swift
//  Caliper
//
//  Created by Kyle on 2020/5/6.
//  Copyright © 2020 kyle. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
        
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow.init(frame: UIScreen.main.bounds)
        
        let rootVC = ViewController.init()
        let naviVC = UINavigationController.init(rootViewController: rootVC)
        
        window.rootViewController = naviVC
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

