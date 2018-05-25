//
//  RTVC reformed.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 12/17/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import UserNotifications
import Foundation
import RealmSwift

class RequestsTableViewController: UITableViewController {

	var realm: Realm! {
		didSet {
			observeChanges()
		}
	}
	
	// Notification objects
	var realmSetObserver: NSObjectProtocol?
	var notificationRunLoop: CFRunLoop? = nil
	var token: NotificationToken!
	var token2: NotificationToken!
	var worker: RequestsObserver?
	
	struct ViewOptions {
		
		enum sortBy: String {
			case date
			case tip
			case popularity
			case songString
			case notes
		}
		
		static var showPlayed = false
		static var startingDate: Date? = nil
		
		static var ascending = false
		
		static var showingRecentsOnly = false {
			didSet {
				if showingRecentsOnly == true {
					ViewOptions.startingDate = Calendar.current.date(byAdding: .hour, value: -24, to: Date())
				} else {
					ViewOptions.startingDate = nil
				}
			}
		}
	}
	
	var sort: ViewOptions.sortBy = .date
	
	var requests: Results<Request>? {
		
		guard realm != nil else { return nil }
		
		let allRequests = realm.objects(Request.self)
		var predicates = [NSPredicate]()
		
		if ViewOptions.showPlayed == false {
			let showPlayedPredicate = NSPredicate(format: "played = false", argumentArray: nil)
			predicates.append(showPlayedPredicate)
		}
		
		if let date = ViewOptions.startingDate {
			let sinceDatePredicate = NSPredicate(format: "date >= %@", argumentArray: [date])
			predicates.append(sinceDatePredicate)
		}
		
		PianistHelper.requestsPredicates = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
		
		let filteredRequests = allRequests.filter(PH.requestsPredicates)
		let sortedRequests = filteredRequests.sorted(byKeyPath: sort.rawValue, ascending: ViewOptions.ascending)
		
		return sortedRequests
	}

	fileprivate func observeChanges() {
		
		//self?.worker = RequestsObserver() // sets up User Notifications, with its own query. Hopefully works in background.
		
		tableView.reloadData()    // initial loading of the table when realmSynced is first set
		
		// Observe changes for table
		DispatchQueue.main.async { [weak self] in
			self?.token = self?.requests?.observe { _ in
				self?.tableView.reloadData()
			}
		}
		
		// Observe changes, in background, for local notifications
		// Note 12/22 late night: This still deosn't work in the background. Trying to check it on iPad in case it only works on an actual device but I can't get it to run from Xcode but only from opening on iPad (it won't trust coming from Xcode for some reason). So I can't debug, and I can't be 100% sure it's running the most current version.
		
		DispatchQueue.global(qos: .background).async { [weak self] in
			
			self?.notificationRunLoop = CFRunLoopGetCurrent()
			
			CFRunLoopPerformBlock(self?.notificationRunLoop, CFRunLoopMode.defaultMode.rawValue) { [weak self] in
				
				let realm: Realm! = (YPB.realmConfig != nil) ? (try! Realm(configuration: YPB.realmConfig)) : (try! Realm())
				let requests = realm.objects(Request.self)
				self?.token2 = requests.observe { changes in
					switch changes {
					case .update(_,_,let insertions, _):
						for index in insertions {
							PH.notifyOf(requests[index])
						}
					default: break
					}
				}
			}
			
			// Run the runloop on this thread until we tell it to stop
			CFRunLoopRun()
		}
		
		NotificationCenter.default.removeObserver(realmSetObserver!)
	}
	
	deinit {
		token?.invalidate()
		token2?.invalidate()
		if let runloop = notificationRunLoop {
			CFRunLoopStop(runloop)
		}
	}


	@objc func filterRequests() {
		let sheet = UIAlertController(title: "Filter requests", message: nil, preferredStyle: .alert)
		
		let showOrHidePlayedString = ViewOptions.showPlayed ? "Hide played" : "Show played"
		let showOrHidePlayedAction = UIAlertAction(title: showOrHidePlayedString, style: .default) { (_) in
			ViewOptions.showPlayed = !ViewOptions.showPlayed
			self.tableView.reloadData()
		}
		sheet.addAction(showOrHidePlayedAction)
		
		let showRecentsString = ViewOptions.showingRecentsOnly ? "Show only requests from last 24 hours" : "Show requests regardless of time"
		let showRecentsAction = UIAlertAction(title: showRecentsString, style: .default) { (_) in
			ViewOptions.showingRecentsOnly = !ViewOptions.showingRecentsOnly
			self.tableView.reloadData()
		}
		sheet.addAction(showRecentsAction)
		
		let showRequestsSinceAction = UIAlertAction(title: "Show requests made since...", style: .default) { (_) in
			let daysAgoAlert = UIAlertController(title: "...days ago (1 = requests in the last 24 hours)", message: nil, preferredStyle: .alert)
			daysAgoAlert.addTextField(configurationHandler: nil)
			daysAgoAlert.textFields?.first?.keyboardType = .numberPad
			
			daysAgoAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
				if let daysAgoString = daysAgoAlert.textFields?.first?.text,
					let daysAgo = Int(daysAgoString) {
					ViewOptions.startingDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())
					self.tableView.reloadData()
				}
			})
			)
			self.present(daysAgoAlert, animated: true)
		}
		sheet.addAction(showRequestsSinceAction)
		
		sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		present(sheet, animated: true)
	}
	
	@objc func addSampleRequest () {
		try! realm.write { [weak self] in
			self?.realm.create(Request.self, value: Request.randomRequest(in: realm), update: false)
		}
		
//		if !Request.addSampleRequest() {
//			let alert = UIAlertController(title: "Can't add request", message: "Can't connect", preferredStyle: .alert)
//			alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//			present(alert, animated: true)
//		}
	}
	
	// MARK: - View Controller Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let addSampleRequestButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSampleRequest))
		let filterButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterRequests))
		navigationItem.rightBarButtonItems = [addSampleRequestButton, filterButton]
		
		realmSetObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name("realm set"), object: nil, queue: OperationQueue.main) { [weak self] _ in self?.realm = YPB.realm
		}
	}
	
	var lastViewed: Date?
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(true)
		lastViewed = Date()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "Request Detail Segue" {
			if let detail = segue.destination as? RequestDetailTableViewController,
				let cell = sender as? RequestTableViewCell {
				
				detail.request = cell.request
				detail.originatingCell = cell
			}
		}
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return requests?.count ?? 0
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath)
		if let cell = cell as? RequestTableViewCell {
			if let requests = self.requests {
				cell.request = requests[indexPath.row]
				if lastViewed != nil && cell.request.date > lastViewed! {
					cell.isNewRequest = true
				}
			}
		}
		return cell
	}
	
	// MARK: Table view delegate
	
	@available(iOS 11.0, *)
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		
		guard let request = self.requests?[indexPath.row] else { return nil }
		
		let markPlayed = UIContextualAction(style: .normal, title: "Mark as Played")
		{ [weak self] (action, sourceView, _) in
			if let realm = self?.realm, let token = self?.token {
				realm.beginWrite()
				request.played = true
				self?.tableView.deleteRows(at: [indexPath], with: .automatic)
				do {
					try realm.commitWrite(withoutNotifying: [token])
				} catch {
					print(error)
				}
			}
		}
		markPlayed.backgroundColor = UIColor(red: 0, green: 0.153, blue: 0, alpha: 1)
			
		let ignoreRequest = UIContextualAction(style: .normal, title: "Ignore")
		{ (action, sourceView, _) in
			// add "ignored" property to Request
			// request.ignored = true
		}
		ignoreRequest.backgroundColor = .red
		
		let lyricSuffix = "%20lyrics"
		
		let searchInSafari = UIContextualAction(style: .normal, title: "Search")
		{ (action, sourceView, _) in
			let pasteboard = UIPasteboard.general
			pasteboard.string = request.songObject?.title ?? request.songString
			if let songWithoutSpaces = request.songObject?.title.replacingOccurrences(of: " ", with: "%20"),
				let searchURL = URL(string: "https://www.google.com/search?q=\(songWithoutSpaces + lyricSuffix)") {
				UIApplication.shared.open(searchURL, options: [:], completionHandler: nil)
			}
		}
		searchInSafari.backgroundColor = .gray
		
		let openInForScore = UIContextualAction(style: .normal, title: "Open")
		{ [weak self] (action, sourceView, _) in
			let pasteboard = UIPasteboard.general
			pasteboard.string = request.songObject?.title ?? request.songString
			if let song = request.songObject?.title {
				if let url = self?.forScorePath(for: song) {
					UIApplication.shared.open(url, options: [:], completionHandler: nil)
				}
			}
		}
		openInForScore.backgroundColor = .blue
		
		let actions = [markPlayed, searchInSafari, openInForScore, ignoreRequest]
		return UISwipeActionsConfiguration(actions: actions)
	}
}
