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
	
	internal func runBlock () {
		block()
	}
	
	internal func startWorker (_ block: @escaping () -> Void) {
		self.block = block
		
		let threadName = String(describing: self).components(separatedBy: .punctuationCharacters)
		
		thread = Thread { [weak self] in
			while self != nil && !self!.thread.isCancelled {
				RunLoop.current.run(mode: .defaultRunLoopMode, before: .distantPast)
			}
			Thread.exit()
		}
		thread.name = "\(threadName) - \(UUID().uuidString)"
		
		thread.start()
		
		perform(#selector(runBlock), on: thread, with: nil, waitUntilDone: false, modes: [RunLoopMode.defaultRunLoopMode.rawValue])
		
	}
	public func stop() {
		thread.cancel()
	}
}

class CacheWorker: BackgroundWorker // should be renamed to what I actually want this worker to do
{
	private var token: NotificationToken?
	typealias change = RealmCollectionChange<Results<Request>>
	
	init(observing collection: Results<Request>, block: @escaping (change)->Void) {
		super.init()
		
		startWorker { [weak self] (_) in
			self?.token = collection.observe(block)
		}
	}
	
	func notifyOf(_ request: Request) {
		
		let content = UNMutableNotificationContent()
		content.title = "Something has happened"
		content.body = "Realm has changed in some way."
		
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
		let request = UNNotificationRequest(identifier: "oneSec", content: content, trigger: trigger)
		let center = UNUserNotificationCenter.current()
		center.add(request, withCompletionHandler: nil)
	}
	
}
