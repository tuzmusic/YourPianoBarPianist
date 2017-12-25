//
//  AppDelegate.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 3/20/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import UserNotifications
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		//print("Documents folder: \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])")

		YPB.setupRealm()
		
		func setupNotifications () {
			
			// MARK: Register and set up Notifications
			
			let center = UNUserNotificationCenter.current()
			center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
				if granted {
					//print("notification permissions granted")
				} else if let error = error {
					print("Error in notification permissions: \(error)")
				}
			}
			
			// Define actions to take from notifications (not all that important)
			
			let dismissAction = UNNotificationAction(identifier: "Dismiss", title: "Dismiss", options: [])
			let detailsAction = UNNotificationAction(identifier: "Details", title: "Details", options: [.foreground])
						
			let newRequestCategory = UNNotificationCategory(identifier: "NewRequest",
												   actions: [dismissAction, detailsAction],
												   intentIdentifiers: [],
												   options: .customDismissAction)
			center.setNotificationCategories([newRequestCategory])
			
			// TO-DO: Last 2 sections of "Managing Your App's Notification Support"
			
		}
		
		setupNotifications()
		
		return true
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		if let realm = YPB.realmSynced {
			
			let localRealm = try! Realm()
			localRealm.beginWrite()
			
			for song in realm.objects(Song.self) {
				localRealm.create(Song.self, value: song, update: false)
			}
			YPB.deleteDuplicateCategories(in: localRealm)
			
			for req in realm.objects(Request.self) {
				localRealm.create(Request.self, value: req, update: false)
			}
			try! localRealm.commitWrite()
		}
	}
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		completionHandler(UNNotificationPresentationOptions.alert)
	}
}

