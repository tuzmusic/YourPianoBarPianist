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
	
	var realm: Realm!
	var notificationToken: NotificationToken!
	
	// This needs to be narrowed down to whatever subset of all requests we're using.
	// And not just filtered in the view, because the realm contains all requests EVER!
	var requests: [Request] {
		if YPB.realmSynced != nil {
			
			// unplayed requests only:
			let allRequests = Array(YPB.realmSynced.objects(Request.self))
			let allUnplayed = allRequests.filter { return !$0.played }
			//let allUnplayedAndNotIgnored = allUnplayed.filter { return !$0.ignored }
			
			return allUnplayed.reversed()
		}
		return []
	}
	
	// Eventually there will be some way or another to filter requests.
	// e.g., All requests or only unfulfilled requests.
	var filteredRequests: [Request]?
	
	func addRequest() {
		if let realm = YPB.realmSynced {
			let user1 = YpbUser.user(firstName: "Jonathan", lastName: "Tuzman", email: "tuzmusic@gmail.com", in: YPB.realm)
			let request1 = Request()
			let requestsInRealm = realm.objects(Request.self).count
			request1.user = user1
			request1.songObject = realm.objects(Song.self)[requestsInRealm]
			//print(request1.songObject)
			request1.notes = "Sample request #\(requestsInRealm)"
			
			try! realm.write {
				realm.create(Request.self, value: request1, update: false)
			}
		} else {
			let alert = UIAlertController(title: "Can't add request", message: "realm = nil", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
			present(alert, animated: true)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRequest))
		
		var realmSet: NSObjectProtocol?
		
		realmSet = NotificationCenter.default.addObserver(forName: NSNotification.Name("realm set"), object: nil, queue: OperationQueue.main) { (notification) in
			self.tableView.reloadData()
			//self.createSampleRequests()
			DispatchQueue.main.async {
				self.notificationToken = YPB.realmSynced.observe { _,_ in
					self.tableView.reloadData()
				}
			}
		NotificationCenter.default.removeObserver(realmSet!)
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
			if requests.isEmpty {
				cell.songTitleLabel.text = "No Requests to Display"
				cell.songTitleLabel.textColor = .gray
			}
			cell.request = filteredRequests?[indexPath.row] ?? requests[indexPath.row]
		}
		
		return cell
	}
	
	// MARK: Table view delegate
	
	@available(iOS 11.0, *)
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		let request = requests[indexPath.row]
		
		let markPlayed = UIContextualAction(style: .normal, title: "Mark as Played") { (action, sourceView, _) in
			try! YPB.realmSynced.write { request.played = true }
		}
		markPlayed.backgroundColor = UIColor(red: 0, green: 0.153, blue: 0, alpha: 1)
		
		let ignoreSong = UIContextualAction(style: .normal, title: "Ignore") { (action, sourceView, _) in
			// add "ignored" property to Request object
			// request.ignored = true
		}
		ignoreSong.backgroundColor = .red
		
		let lyricSuffix = "%20lyrics"
	
		let searchInSafari = UIContextualAction(style: .normal, title: "Search") { (action, sourceView, _) in
			let pasteboard = UIPasteboard.general
			pasteboard.string = request.songObject?.title ?? request.songString
			if let songWithoutSpaces = request.songObject?.title.replacingOccurrences(of: " ", with: "%20"),
				let searchURL = URL(string: "https://www.google.com/search?q=\(songWithoutSpaces + lyricSuffix)") {
					UIApplication.shared.open(searchURL, options: [:], completionHandler: nil)
				}
			
		}
		
		let actions = [markPlayed, searchInSafari, ignoreSong]
		return UISwipeActionsConfiguration(actions: actions)
	}
	
	// MARK: for testing
	
	func createSampleRequests() {
		
		let user1 = YpbUser.user(firstName: "Jonathan", lastName: "Tuzman", email: "tuzmusic@gmail.com", in: YPB.realmSynced)
		let user2 = YpbUser.user(firstName: "Holly", lastName: "Shulman", email: "holly@gmail.com", in: YPB.realmSynced)
		
		let request1 = Request()
		request1.user = user1
		request1.songObject = YPB.realmSynced.objects(Song.self)[0]
		request1.notes = "Notes for Jonathan's request"
		
		let request2 = Request()
		request2.user = user2
		request2.songObject = YPB.realmSynced.objects(Song.self)[1]
		request2.notes = "Notes for Holly's request"
		
		try! YPB.realmSynced.write {
			YPB.realmSynced.delete(YPB.realmSynced.objects(Request.self))
			YPB.realmSynced.create(Request.self, value: request1, update: false)
			YPB.realmSynced.create(Request.self, value: request2, update: false)
		}
	}
}
