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

class RequestsTableViewController2: UITableViewController {
    
    var realm: Realm!
    var notificationToken: NotificationToken!
    
    
    struct ViewOptions {
        static var showPlayed = false
        static var startingDate: Date? = nil
        enum sortBy: String {
            case date
            case tip
            case popularity
            case songString
            case notes
        }
        static var ascending = false
    }
    
    
    var sort: ViewOptions.sortBy = .date
    
    var requests: Results<Request>? {
        
        if let realm = YPB.realmSynced {
            let allRequests = realm.objects(Request.self)
            
            let showPlayedPredicate = NSPredicate(format: "played = %@", argumentArray: [ViewOptions.showPlayed])
            var predicates = [showPlayedPredicate]
            
            if let date = ViewOptions.startingDate {
                let sinceDatePredicate = NSPredicate(format: "date >= %@", argumentArray: [date])
                predicates.append(sinceDatePredicate)
            }
            
            let filteredRequests = allRequests.filter(NSCompoundPredicate(andPredicateWithSubpredicates: predicates))
            let sortedRequests = filteredRequests.sorted(byKeyPath: sort.rawValue, ascending: false)
            return sortedRequests
        }
        
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TESTING - button for adding sample requests
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addSampleRequest))
        let filterButton = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterRequests))
        navigationItem.rightBarButtonItems = [addButton, filterButton]
        
        var realmSet: NSObjectProtocol?
        
        // When the realm is set, load the table and do all the other stuff
        realmSet = NotificationCenter.default.addObserver(forName: NSNotification.Name("realm set"), object: nil, queue: OperationQueue.main) { (_) in
            DispatchQueue.main.async {
                if let requests = self.requests {
                    self.notificationToken = requests.observe { change in
                        switch change {
                        case .initial:
                            self.tableView.reloadData()
                        case .update(_,let additions,_,_):
                            self.tableView.reloadData()
                            for index in additions {
                                self.notifyOf(requests[index])
                            }
                        case .error(let error):
                            print(error)
                        }
                    }
                }
            }
            NotificationCenter.default.removeObserver(realmSet!)
        }
        
    }
    
    func addSampleRequest () {
        if !YPB.addSampleRequest() {
            let alert = UIAlertController(title: "Can't add request", message: "realm = nil", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true)
        }
    }
    
    func filterRequests() {
        let sheet = UIAlertController(title: "Filter requests", message: nil, preferredStyle: .alert)
        
        let showOrHidePlayedString = ViewOptions.showPlayed ? "Hide played" : "Show played"
        let showOrHidePlayedAction = UIAlertAction(title: showOrHidePlayedString, style: .default) { (_) in
            ViewOptions.showPlayed = !ViewOptions.showPlayed
            self.tableView.reloadData()
        }
        sheet.addAction(showOrHidePlayedAction)
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
        return requests?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath)
        if let cell = cell as? RequestTableViewCell, let requests = self.requests {
            if requests.isEmpty {
                cell.songTitleLabel.text = "No Requests to Display"
                cell.songTitleLabel.textColor = .gray
            } else {
                cell.request = requests[indexPath.row]
            }
        }
        return cell
    }
    
    // MARK: Table view delegate
    
    @available(iOS 11.0, *)
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let request = self.requests?[indexPath.row] else { return nil }
        
        let markPlayed = UIContextualAction(style: .normal, title: "Mark as Played") { (action, sourceView, _) in
            YPB.realmSynced.beginWrite()
            request.played = true
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            do {
                try YPB.realmSynced.commitWrite(withoutNotifying: [self.notificationToken])
            } catch {
                print(error)
            }
        }
        markPlayed.backgroundColor = UIColor(red: 0, green: 0.153, blue: 0, alpha: 1)
        
        let ignoreSong = UIContextualAction(style: .normal, title: "Ignore") { (action, sourceView, _) in
            // add "ignored" property to Request
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

