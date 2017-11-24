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
	
	override func viewDidLoad() {
		super.viewDidLoad()
//		setupRealm()

	}
	func updateList() {
		// TODO: Add sorting options
		// TODO: This does not support live deleting of objects (from the realm browser)
		if requests.realm == nil {
			requests.removeAll()
			for request in realm.objects(Request.self) {
				requests.append(request)
			}
		}
		tableView.reloadData()
	}
	
	func newSpinner() -> UIActivityIndicatorView {
		let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
		spinner.color = UIColor.gray
		spinner.hidesWhenStopped = true
		spinner.startAnimating()
		let spinnerOrigin = CGPoint(x: self.view.frame.midX - 20, y: self.view.frame.midY - 20)
		spinner.frame = CGRect(origin: spinnerOrigin, size: CGSize(width: 40, height: 40))
		self.view.addSubview(spinner)
		return spinner
	}
	
	let amazonURL = "ec2-54-208-237-32.compute-1.amazonaws.com"
	let address = "54.208.237.32:9080/~/yourPianoBarRequests"
	var httpURL: URL! { return URL(string: "http://" + address)! }
	var realmURL: URL! { return URL(string: "realm://" + address)! }

	func setupRealmWithoutUser() {
		let spinner = self.newSpinner()
		DispatchQueue.main.async {
			self.realm = try! Realm(fileURL: self.httpURL)
			self.updateList()
			spinner.stopAnimating()
		}
	}
	
	func setupRealmOffline() {
		realm = try! Realm()
		let userURL = realm.configuration.fileURL!.deletingLastPathComponent().appendingPathComponent("offlineTuzRequests.realm")
		realm = try! Realm(fileURL: userURL)
		debugPrint("Path to realm file: " + realm.configuration.fileURL!.absoluteString)

	}
	
	func setupRealm() {
		let username = "tuzmusic@gmail.com"
		let password = "samiam"
		
		let localHTTP = URL(string:"http://54.208.237.32:9080")!
		let realmAddress = URL(string:"realm://54.208.237.32:9080/~/yourPianoBarRequests")!
		
		/* to SSH in via terminal:
		cd /Users/TuzsNewMacBook/Library/Mobile\ Documents/com\~apple\~CloudDocs/Misc\ Stuff\ -\ iCloud\ drive/Programming/IMPORTANT\ Server\ Stuff
		ssh -i "YourPianoBarKeyPair.pem" ubuntu@ec2-54-208-237-32.compute-1.amazonaws.com
		
		sudo systemctl start realm-object-server
		
		*/
		
		SyncUser.logIn(with: .usernamePassword(username: username, password: password), server: localHTTP) {
			user, error in
			guard let user = user else {
				let alert = UIAlertController(title: "Error",
				                              //message: String(describing: error),
					message: "Could not log in",
					preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
				self.present(alert, animated: true, completion: nil)
				print(String(describing: error!))
				return
			}
			
			DispatchQueue.main.async {
				
				// Open Realm
				var configuration = Realm.Configuration()
				configuration.syncConfiguration = SyncConfiguration(user: user, realmURL: realmAddress)
				
				do {
					self.realm = try Realm(configuration: configuration)
				} catch {
					print(error)
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
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == Storyboard.ImportSongsTable, let dvc = segue.destination as? ImportSongsTableViewController {
		
			let configURL = Realm.Configuration().fileURL!.deletingLastPathComponent().appendingPathComponent("songsLocal.realm")
			do {
				let songsLocalRealm = try Realm(fileURL: configURL)
				dvc.importingSongs = Array(songsLocalRealm.objects(Song.self))
					.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == ComparisonResult.orderedAscending }

			} catch {
				print(error)
			}
		}
	}
}
