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
        
		let now = Date()
		let secondsAgo = DateInterval(start: time, end: now).duration
		let minutesAgo = secondsAgo / 60
		let hoursAgo = Int(minutesAgo / 60)
		let timeAgo = "\(hoursAgo)h \(Int(minutesAgo.truncatingRemainder(dividingBy: 60)))m ago"

        return timeAgo
	}
	
	func updateUI() {
		var userName = ""
		if let firstName = request.user?.firstName,
			let lastName = request.user?.lastName {
			userName = "\(firstName) \(lastName)"
		}
		if !request.userString.isEmpty && request.userString != userName {
			userName = "\(request.userString) (\(userName))"
		}
		userDateLabel.text = "\(userName) - \(timeSince(time: request.date))"
		songTitleLabel.text = request.songObject?.title ?? request.songString
		artistLabel.text = request.songObject?.artist.name ?? nil
		notesLabel.text = request.notes
		tipLabel.text = request.tip != nil ? "$\(request.tip!)" : "$0"
	}
}
