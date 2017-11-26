//
//  RequestsTableViewController.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 5/31/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift

class RequestsTableViewController: UITableViewController {
	
	let realm = YPB.realm
	var notificationToken: NotificationToken!

	// This needs to be narrowed down to whatever subset of all requests we're using.
	var requests: [Request] {
		return Array(realm.objects(Request.self))
	}
	
	// Eventually there will be some way or another to filter requests.
	 // e.g., All requests or only unfulfilled requests.
	var filteredRequests: [Request]?
	
	func addRequest() {

		let user1 = YpbUser.user(firstName: "Jonathan", lastName: "Tuzman", email: "tuzmusic@gmail.com", in: YPB.realm)
		let request1 = Request()
		let requestsInRealm = realm.objects(Request.self).count
		request1.user = user1
		request1.songObject = realm.objects(Song.self)[requestsInRealm]
		request1.notes = "Sample request #\(requestsInRealm)"
		
		try! realm.write {
			realm.add(request1)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRequest))

		createSampleRequests()
		
		DispatchQueue.main.async {
			self.notificationToken = self.realm.observe { _,_ in
				self.tableView.reloadData()
			}
		}
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return filteredRequests?.count ?? requests.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath)
		if let cell = cell as? RequestTableViewCell {
			cell.request = filteredRequests?[indexPath.row] ?? requests[indexPath.row]
		}
		
		return cell
	}
	
	func createSampleRequests() {
		let user1 = YpbUser.user(firstName: "Jonathan", lastName: "Tuzman", email: "tuzmusic@gmail.com", in: YPB.realm)
		let user2 = YpbUser.user(firstName: "Holly", lastName: "Shulman", email: "holly@gmail.com", in: YPB.realm)
		
		let request1 = Request()
		request1.user = user1
		request1.songObject = YPB.realm.objects(Song.self)[0]
		request1.notes = "Notes for Jonathan's request"
		
		let request2 = Request()
		request2.user = user2
		request2.songObject = YPB.realm.objects(Song.self)[1]
		request2.notes = "Notes for Holly's request"
		
		try! YPB.realm.write {
			realm.delete(realm.objects(Request.self))
			realm.create(Request.self, value: request1, update: false)
			realm.create(Request.self, value: request2, update: false)
		}
	}
	
	
}
