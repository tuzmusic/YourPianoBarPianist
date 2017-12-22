////
////  RequestsTableViewController.swift
////  YourPianoBarPianist
////
////  Created by Jonathan Tuzman on 5/31/17.
////  Copyright © 2017 Jonathan Tuzman. All rights reserved.
////
//
//import UIKit
//import UserNotifications
//import Foundation
//import RealmSwift
//
//class RequestsTableViewControllerSECONDBACKUP : UITableViewController {
//	
//    var realm: Realm? {
//        didSet {
//            if self.realm != nil {
//                observeChangesWithWorker()
//            }
//        }
//    }
//	
//    var token: NotificationToken!
//    var worker: RequestsObserver!
//	
//    func observeChangesWithWorker() {
//        worker = RequestsObserver()
//        worker.observeChanges(filteredWith: nil, inRealmWith: self.realm!.configuration) { [weak self] change in
//            self?.tableView.reloadData()
//            self?.notify()
//        }
//    }
//	
//    func observeChanges() {
//        DispatchQueue.main.async {
//            if let requests = self.requests {
//                self.token = requests.observe { change in
//                    switch change {
//                    case .initial: self.tableView.reloadData()
//                    case .update(_,let additions,_,_): self.tableView.reloadData()
//                    for index in additions {
//                        //self.notifyOf(requests[index])
//                        }
//                    case .error(let error): print(error)
//                    }
//                }
//            }
//        }
//    }
//	
//    struct ViewOptions {
//        static var showPlayed = false
//        static var startingDate: Date? = nil
//        enum sortBy: String {
//            case date
//            case tip
//            case popularity
//            case songString
//            case notes
//        }
//        static var ascending = false
//    }
//	
//    var sort: ViewOptions.sortBy = .date
//	
//    var requests: Results<Request>? {
//	
//        if let allRequests = realm?.objects(Request.self) {
//		
//            let showPlayedPredicate = NSPredicate(format: "played = %@", argumentArray: [ViewOptions.showPlayed])
//            var predicates = [showPlayedPredicate]
//		
//            if let date = ViewOptions.startingDate {
//                let sinceDatePredicate = NSPredicate(format: "date >= %@", argumentArray: [date])
//                predicates.append(sinceDatePredicate)
//            }
//		
//            let filteredRequests = allRequests.filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
//            let sortedRequests = filteredRequests.sorted(byKeyPath: sort.rawValue, ascending: false)
//            return sortedRequests
//        }
//	
//        return nil
//    }
//	
//    override func viewDidLoad() {
//        super.viewDidLoad()
//	
//        setupInstanceRealm()
//	
//        let addSampleRequestButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSampleRequest))
//        let filterButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterRequests))
//        navigationItem.rightBarButtonItems = [addSampleRequestButton, filterButton]
//    }
//	
//    func addSampleRequest () {
//        if let realm = realm {
//            let user = YpbUser.user(firstName: "Jonathan", lastName: "Tuzman", email: "tuzmusic@gmail.com", in: realm)
//            let request = Request()
//            let requestsInRealm = realm.objects(Request.self).count
//            request.user = user
//            request.songObject = realm.objects(Song.self)[requestsInRealm]
//            request.songString = request.songObject!.title
//            request.notes = "Sample request #\(requestsInRealm)"
//            try! realm.write {
//                realm.create(Request.self, value: request, update: false)
//            }
//        } else {
//            let alert = UIAlertController(title: "Can't add request", message: "realm = nil", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            present(alert, animated: true)
//        }
//    }
//	
//    func filterRequests() {
//        let sheet = UIAlertController(title: "Filter requests", message: nil, preferredStyle: .alert)
//	
//        let showOrHidePlayedString = ViewOptions.showPlayed ? "Hide played" : "Show played"
//        let showOrHidePlayedAction = UIAlertAction(title: showOrHidePlayedString, style: .default) { (_) in
//            ViewOptions.showPlayed = !ViewOptions.showPlayed
//            self.tableView.reloadData()
//        }
//        sheet.addAction(showOrHidePlayedAction)
//        let showRequestsSinceAction = UIAlertAction(title: "Show requests made since...", style: .default) { (_) in
//            let daysAgoAlert = UIAlertController(title: "...days ago (1 = requests in the last 24 hours)", message: nil, preferredStyle: .alert)
//            daysAgoAlert.addTextField(configurationHandler: nil)
//            daysAgoAlert.textFields?.first?.keyboardType = .numberPad
//		
//            daysAgoAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
//                if let daysAgoString = daysAgoAlert.textFields?.first?.text,
//                    let daysAgo = Int(daysAgoString) {
//                    ViewOptions.startingDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())
//                    self.tableView.reloadData()
//                }
//            })
//            )
//            self.present(daysAgoAlert, animated: true)
//        }
//        sheet.addAction(showRequestsSinceAction)
//        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        present(sheet, animated: true)
//    }
//	
//    func notify () {
//	
//        // THIS WORKS! But notifyOf(_) only gets called if app is in foreground.
//	
//        let content = UNMutableNotificationContent()
//        content.title = "Something has happened"
//        content.body = "Realm has changed in some way."
//	
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//        let request = UNNotificationRequest(identifier: "oneSec", content: content, trigger: trigger)
//        let center = UNUserNotificationCenter.current()
//        center.add(request, withCompletionHandler: nil)
//    }
//	
//    // MARK: - Table view data source
//	
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//	
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return requests?.count ?? 0
//    }
//	
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath)
//        if let cell = cell as? RequestTableViewCell {
//            if let requests = self.requests {
//                cell.request = requests[indexPath.row]
//            } else if requests == nil {
//                cell.songTitleLabel.text = "No Requests to Display"
//                cell.songTitleLabel.textColor = .gray
//            }
//        }
//        return cell
//    }
//	
//    // MARK: Table view delegate
//	
//    @available(iOS 11.0, *)
//    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//	
//        guard let request = self.requests?[indexPath.row] else { return nil }
//	
//        let markPlayed = UIContextualAction(style: .normal, title: "Mark as Played") { [weak self] (action, sourceView, _) in
//            if let realm = self?.realm, let token = self?.token {
//                realm.beginWrite()
//                request.played = true
//                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
//                do {
//                    try realm.commitWrite(withoutNotifying: [token])
//                } catch {
//                    print(error)
//                }
//            }
//        }
//        markPlayed.backgroundColor = UIColor(red: 0, green: 0.153, blue: 0, alpha: 1)
//	
//        let ignoreSong = UIContextualAction(style: .normal, title: "Ignore") { (action, sourceView, _) in
//            // add "ignored" property to Request
//            // request.ignored = true
//        }
//        ignoreSong.backgroundColor = .red
//	
//        let lyricSuffix = "%20lyrics"
//	
//        let searchInSafari = UIContextualAction(style: .normal, title: "Search") { (action, sourceView, _) in
//            let pasteboard = UIPasteboard.general
//            pasteboard.string = request.songObject?.title ?? request.songString
//            if let songWithoutSpaces = request.songObject?.title.replacingOccurrences(of: " ", with: "%20"),
//                let searchURL = URL(string: "https://www.google.com/search?q=\(songWithoutSpaces + lyricSuffix)") {
//                UIApplication.shared.open(searchURL, options: [:], completionHandler: nil)
//            }
//        }
//	
//        let actions = [markPlayed, searchInSafari, ignoreSong]
//        return UISwipeActionsConfiguration(actions: actions)
//    }
//	
//    func setupInstanceRealm() {
//        let info = YPB.RealmConstants.self
//	
//        SyncUser.logIn(with: info.userCred, server: info.publicDNS) { (user, error) in
//            guard let user = user else {
//                print("Could not access server. Using local Realm [default configuration]. Error:")
//                print(error!)
//                return
//            }
//		
//            DispatchQueue.main.async { [weak self] in
//                let syncConfig = SyncConfiguration(user: user, realmURL: info.realmAddress)
//                let realmConfig = Realm.Configuration(syncConfiguration:syncConfig)
//                self?.realm = try! Realm(configuration: realmConfig)
//            }
//        }
//    }
//}
//
//
