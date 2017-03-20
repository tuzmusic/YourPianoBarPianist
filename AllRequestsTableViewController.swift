//
//  AllRequestsTableViewController.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 3/20/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift

class AllRequestsTableViewController: UITableViewController {
	
	var realm: Realm!
	var requests = List<Request>()
	var notificationToken: NotificationToken!
	var lastUpdate: Date?
	
	var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		spinner.color = UIColor.gray
		
		setupRealm()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
		if let window = view.window {
			let spinnerOrigin = CGPoint(x: window.center.x - 20, y: window.center.y - 20)
			spinner.frame = CGRect(origin: spinnerOrigin, size: CGSize(width: 40, height: 40))
			spinner.hidesWhenStopped = true
			spinner.startAnimating()
			view.addSubview(spinner)
		}
	}
	
	func setupRealm() {
		let username = "tuzmusic@gmail.com"
		let password = "samiam"
		let localHTTP = "http://54.208.237.32:9080"
		let realmAddress = "realm://54.208.237.32:9080/~/yourPianoBarRequests"
		
		SyncUser.logIn(with: .usernamePassword(username: username, password: password), server: URL(string: localHTTP)!) {
			user, error in
			guard let user = user else {
				let alert = UIAlertController(title: "Error", message: String(describing: error), preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				self.present(alert, animated: true, completion: nil)
				print(String(describing: error!))
				return
			}
			
			
			DispatchQueue.main.async {
				
				// Open Realm
				let configuration = Realm.Configuration(
					syncConfiguration: SyncConfiguration (user: user, realmURL: URL(string: realmAddress)!)
				)
				self.realm = try! Realm(configuration: configuration)
				
				func updateList() {
					
					// TODO: Add sorting options
					// TODO: This does not support live deleting of objects (from the realm browser)
					// TODO: Streamline this code. lastUpdate being optional is a bit of a problem.
					if self.requests.realm == nil {
						if self.requests.isEmpty {
							for request in self.realm.objects(Request.self) {
								self.requests.append(request)
							}
						} else {
							for request in self.realm.objects(Request.self) where request.date > self.lastUpdate! {
								self.requests.append(request)
							}
						}
					}
					self.spinner.stopAnimating()
					self.tableView.reloadData()
					self.lastUpdate = Date()
				}
				updateList()
				
				// Notify us when Realm changes
				self.notificationToken = self.realm.addNotificationBlock {notification in
					//print(notification) 
					//This just prints "(RealmSwift.Realm.Notification.didChange, RealmSwift.Realm)", useless
					updateList()
				}
			}
		}
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return requests.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return requests[section].notes.isEmpty ? 1 : 2
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return "Request from \(requests[section].userString)"
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		let request = requests[indexPath.section]
		var cellContents = ""
		switch indexPath.row {
		case 0:
			cellContents = request.songString
			cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
		case 1: cellContents = "Notes: \(request.notes)"
		default: break
		}
		
		cell.textLabel?.text = cellContents
		
		return cell
	}
	
	
	
}
