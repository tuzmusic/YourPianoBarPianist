//
//  AppDelegate.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 3/20/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		print("Documents folder: \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])")

		YPB.setupRealm()
		
		// MARK: Register and set up Notifications
		
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
			if granted {
				print("notification permissions granted")
			} else if let error = error {
				print("Error: \(error)")
			}
		}
		
		let generalCategory = UNNotificationCategory(identifier: "GENERAL",
											actions: [],
											intentIdentifiers: [],
											options: .customDismissAction)
				
		// Register the category.
		center.setNotificationCategories([generalCategory])
		
		return true
	}
}

