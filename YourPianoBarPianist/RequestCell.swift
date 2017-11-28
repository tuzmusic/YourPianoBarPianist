//
//  RequestCell.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 5/31/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift

class RequestTableViewCell: UITableViewCell {
	
	var request = Request() {
		didSet {
			updateUI()
		}
	}
	
	@IBOutlet weak var userDateLabel: UILabel!
	@IBOutlet weak var tipLabel: UILabel!
	@IBOutlet weak var songTitleLabel: UILabel!
	@IBOutlet weak var artistLabel: UILabel!
	@IBOutlet weak var notesLabel: UILabel!
	
	func timeSince(time: Date) -> String {
		
		// this used to divide by "hour" instead of "24", whatever that meant.
		let hoursAgo = DateInterval(start: time, end: Date()).duration / 24
		let minutesAgo = hoursAgo * 60
		let timeAgo = "\(Int(minutesAgo / 60))h \(Int(minutesAgo.truncatingRemainder(dividingBy: 60)))m ago"
		
		return timeAgo
	}
	
	func updateUI() {
		var userName = ""
		if let firstName = request.user?.firstName,
			let lastName = request.user?.lastName {
			userName = "\(firstName) \(lastName)"
		}
		if !request.userString.isEmpty {
			// If they've entered a name, we assume that it's a nickname or something like that, so we show the pianist their real name in parens.
			// TO-DO: This should be handled more "automatically," somewhere else.
			// If the list shows the name, and the name in parentheses, that's of the didSet on Request.user
			userName = "\(request.userString) (\(userName))"
		}
		userDateLabel.text = "\(userName) - \(timeSince(time: request.date))"
		songTitleLabel.text = request.songObject?.title ?? request.songString
		artistLabel.text = request.songObject?.artist.name ?? nil
		notesLabel.text = request.notes
		tipLabel.text = request.tip != nil ? "$\(request.tip!)" : ""
	}
	
	@IBAction func markComplete(_ sender: UIButton) {
		
		// NOTE: This doesn't change the appearance of the request.
		// I really shouldn't be doing this with a button, anyway, but rather with a swipe! (which would go in the RequestTVC delegate)
		
		try! YPB.realm.write {
			request.played = true
		}
	}
	
	@IBAction func copyAndOpenApp(_ sender: UIButton) {
		let pasteboard = UIPasteboard.general
		pasteboard.string = request.songObject?.songDescription ?? request.songString
		
	}
	
	
}
