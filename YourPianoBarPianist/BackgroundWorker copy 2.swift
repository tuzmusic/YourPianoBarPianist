////
////  BackgroundWorker.swift
////  YourPianoBarPianist
////
////  Created by Jonathan Tuzman on 12/9/17.
////  Copyright © 2017 Jonathan Tuzman. All rights reserved.
////
//
//import Foundation
//import Realm
//import RealmSwift
//import UserNotifications
//
//class BackgroundWorkerSECONDBACKUP: NSObject {
//    private var thread: Thread!
//    private var block: (() -> Void)!
//    
//    internal func runBlock () {
//        block()
//    }
//    
//    internal func startWorker (_ block: @escaping () -> Void) {
//        self.block = block
//        thread = Thread { [weak self] in
//            while self != nil && !self!.thread.isCancelled {
//                RunLoop.current.run(mode: .defaultRunLoopMode, before: .distantPast)
//            }
//            Thread.exit()
//        }
//        thread.start()
//        perform(#selector(runBlock), on: thread, with: nil, waitUntilDone: false, modes: [RunLoopMode.defaultRunLoopMode.rawValue])
//    }
//    public func stop() {
//        thread.cancel()
//    }
//}
//
//class RequestsObserver: BackgroundWorker {
//    private var token: NotificationToken?
//    typealias change = RealmCollectionChange<Results<Request>>
//    
//    // IMPORTANT NOTE:
//    /* The filtering of requests happens on the main thread in RTVC. observeChanges here does its own query and is currently not filtered, which means unless RTVC's results are also not filtered, there will be an error if we use indexes. That's why the RTVC.observeChangesWithWorker method currently just reloads the table and sends a notification without an object in it.
// */
//    
//    func observeChanges (filteredWith predicates: [NSPredicate]?, inRealmWith config: Realm.Configuration, using block: @escaping (RealmCollectionChange<Results<Request>>)->Void) {
//        
//        startWorker { [weak self] (_) in
//            // Create a realm on the new thread
//            var realm: Realm? {
//                didSet {
//                    if let realm = realm {
//                        let results = realm.objects(Request.self)
//                        self?.token = results.observe(block)
//                    }
//                }
//            }
//            realm = try! Realm(configuration: config)
//        }
//    }
//    
//    convenience init(observing collection: Results<Request>, block: @escaping (change)->Void) {
//        self.init()
//        
//        startWorker { [weak self] (_) in
//            self?.token = collection.observe(block)
//        }
//    }
//}
//
