//
//  BackgroundWorker.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 12/9/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import UserNotifications

class BackgroundWorker: NSObject {
	private var thread: Thread!
	private var block: (() -> Void)!
	
	@objc internal func runBlock () {
		block()
	}
	
	internal func startWorker (_ block: @escaping () -> Void) {
		self.block = block
		
		thread = Thread { [weak self] in
			while self != nil && !self!.thread.isCancelled {
				RunLoop.current.run(mode: .defaultRunLoopMode, before: .distantPast)
			}
			Thread.exit()
		}
		
		thread.start()
		
		perform(#selector(runBlock), on: thread, with: nil, waitUntilDone: false, modes: [RunLoopMode.defaultRunLoopMode.rawValue])
		
	}
	public func stop() {
		thread.cancel()
	}
}

class RequestsObserver: BackgroundWorker
{
	private var token: NotificationToken?
	
	override init() {
		super.init()
		startWorker {
			OperationQueue.main.addOperation { [weak self] in
				if let realm = YPB.realmSynced {
					self?.token = realm.objects(Request.self).observe { changes in
						switch changes {
						case .update(_,_,let insertions, _):
							for index in insertions {
								self?.notifyOf(requests[index])
							}
						default: break
						}
					}
				}
			}
		}
	}
	
	func notifyOf(_ request: Request) {
		
		let content = UNMutableNotificationContent()
		content.title = "New Request!"
		content.body = request.userString + " wants to hear " + (request.songObject?.title ?? request.songString)
		
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
		let request = UNNotificationRequest(identifier: "oneSec", content: content, trigger: trigger)
		let center = UNUserNotificationCenter.current()
		center.add(request, withCompletionHandler: nil)
	}
	
	
}
