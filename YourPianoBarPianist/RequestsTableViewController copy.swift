    //
    //  RequestsTableViewController.swift
    //  YourPianoBarPianist
    //
    //  Created by Jonathan Tuzman on 5/31/17.
    //  Copyright © 2017 Jonathan Tuzman. All rights reserved.
    //

    import UIKit
    import UserNotifications
    import Foundation
    import RealmSwift

    class RequestsTableViewControllerBACKUP: UITableViewController {
        
        var realm: Realm!
        var token: NotificationToken!
        
        var worker = RequestsObserver()
        
        var requests: [Request] {
            if let realm = YPB.realmSynced {
                
                let results = realm.objects(Request.self).filter("played = false").sorted(byKeyPath: "date", ascending: false)
                
                return Array(results)
            }
            return []
        }
        
        // Eventually there will be some way or another to filter requests.
        // e.g., All requests or only unfulfilled requests.
        var filteredRequests: [Request]?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSampleRequest))
            
            var realmSetObserver: NSObjectProtocol?
            
            realmSetObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name("realm set"), object: nil, queue: OperationQueue.main) { (_) in
                self.tableView.reloadData()    // initial loading of the table when realmSynced is first set

			DispatchQueue.main.async {
                    self.token = YPB.realmSynced.observe { _,_ in
                        self.tableView.reloadData()
                        if !self.requests.isEmpty {
                            self.notifyOf(self.requests.first!)
                        }
                    }
                }
            NotificationCenter.default.removeObserver(realmSetObserver!)
            }
            
        }
        
	@objc func addSampleRequest () {
            if !Request.addSampleRequest() {
                let alert = UIAlertController(title: "Can't add request", message: "realm = nil", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true)
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
    }

