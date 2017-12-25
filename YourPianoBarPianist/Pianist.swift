//
//  Pianist.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 12/17/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift
import UserNotifications

typealias PH = PianistHelper
typealias Pred = NSCompoundPredicate

class PianistHelper {
	static var requestsPredicates = NSCompoundPredicate()
	
	class func notifyOf(_ request: Request) {
		
		let content = UNMutableNotificationContent()
		content.title = "New Request!"
		content.body = request.userString + " wants to hear \"" + (request.songObject?.title ?? request.songString) + "\""
		content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
		
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
		let request = UNNotificationRequest(identifier: "oneSec", content: content, trigger: trigger)
		let center = UNUserNotificationCenter.current()
		center.add(request, withCompletionHandler: nil)
	}
}
