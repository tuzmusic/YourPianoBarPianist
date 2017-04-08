//
//  AppDelegate.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 3/20/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
		//print("Documents folder: \(documentsPath)")
		return true
	}
}

