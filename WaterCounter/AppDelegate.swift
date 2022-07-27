//
//  AppDelegate.swift
//  WaterCounter
//
//  Created by Александр Борисов on 16.07.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = WaterCounterViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
}

