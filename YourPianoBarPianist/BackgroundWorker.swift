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
	
	@objc internal func runBlock () { block() }
	
	internal func startWorker (_ block: @escaping () -> Void) {
		self.block = block
		
		thread = Thread { [weak self] in
			while self != nil && !self!.thread.isCancelled {
				RunLoop.current.run(mode: .defaultRunLoopMode, before: .distantPast)
			}
			Thread.exit()
		}
		thread.name = "Request Observer Thread"
		thread.start()
		
		perform(#selector(runBlock), on: thread, with: nil, waitUntilDone: false, modes: [RunLoopMode.defaultRunLoopMode.rawValue])
	}
	public func stop() {
		thread.cancel()
	}
}

class RequestsObserver: BackgroundWorker {
	private var token: NotificationToken?
	
	override init() {
		super.init()
		startWorker {
			// 12/21 - THIS DOESN'T WORK IN THE BACKGROUND, DAMMIT!
			// Passing the realmConfig like this works (doesn't crash), but still doesn't get the notifications in the background.
			[weak self] in
			if let realm = try? Realm(configuration: YPB.realmConfig) {
				let requests = realm.objects(Request.self)
				self?.token = requests.observe { changes in
					switch changes {
					case .update(_,_,let insertions, _):
						for index in insertions {
							PH.notifyOf(requests[index])
						}
					default: break
					}
				}
			}
		}
	}
	
	
}
