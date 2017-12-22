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

class BackgroundWorkerBACKUP: NSObject {
	private var thread: Thread!
	private var block: (() -> Void)!
	
	@objc internal func runBlock () {
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

class BACKUPRequestsObserverBACKUP: BackgroundWorker // should be renamed to what I actually want this worker to do
{
	private var token: NotificationToken?
	
    var thisBlock: (() -> Void)!
    
     init(block: (() -> Void)!) {
		super.init()
        self.thisBlock = block
		startWorker { [weak self] in
			
			var realmSetObserver: NSObjectProtocol?
			realmSetObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name("realm set"), object: nil, queue: OperationQueue.main) { (_) in
					if let realm = YPB.realmSynced {
						let requests = realm.objects(Request.self).filter("played = false")
						self?.token = requests.observe { changes in
							switch changes {
							case .update(_,_,let insertions, _):
								for index in insertions{
									self?.notifyOf(requests[index])
								}
							default: break
							}
						}
					}
				NotificationCenter.default.removeObserver(realmSetObserver!)
			}
			
			/* if let realm = YPB.realmSynced {
				let requests = realm.objects(Request.self).filter("played = false")
				self?.token = requests.observe { changes in
					switch changes {
					case .update(_,_,let insertions, _):
						for index in insertions{
							self?.notifyOf(requests[index])
						}
					default: break
					}
					
				}
			} */
		}
	}
	
	func notifyOf(_ request: Request) {
		
		// THIS WORKS! But notifyOf(_) only gets called if app is in foreground.
		
		let content = UNMutableNotificationContent()
		content.title = "Something has happened"
		content.body = "Realm has changed in some way."
		
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
		let request = UNNotificationRequest(identifier: "oneSec", content: content, trigger: trigger)
		let center = UNUserNotificationCenter.current()
		center.add(request, withCompletionHandler: nil)
	}
	
	
}
