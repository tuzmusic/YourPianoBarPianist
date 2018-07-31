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
			formulateRequestStrings()
		}
	}
	// MARK - Model
	var nameString: String! { didSet { updateUI() } }
	var timeString: String! { didSet { updateUI() } }
	var songString: String! { didSet { updateUI() } }
	var artistString: String! { didSet { updateUI() } }

	var isNewRequest = false
	
	func timeSince(time: Date) -> String! {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .short
		return formatter.string(from: time, to: Date())
	}
	
	func formulateRequestStrings() {
		if let firstName = request.user?.firstName, let lastName = request.user?.lastName {
			nameString = "\(firstName) \(lastName)"
		}
		if !request.userString.isEmpty && request.userString != nameString {
			nameString = "\(request.userString) (\(nameString))"
		}
		
		timeString = timeSince(time: request.date) + " ago"
		
		songString = request.songObject?.title ?? request.songString
		
		artistString = request.songObject?.artist.name ?? nil
	}

	// MARK: - View
	@IBOutlet weak var userDateLabel: UILabel!
	@IBOutlet weak var tipLabel: UILabel!
	@IBOutlet weak var songTitleLabel: UILabel!
	@IBOutlet weak var artistLabel: UILabel!
	@IBOutlet weak var notesLabel: UILabel!
	
	
	func updateUI() {

		if isNewRequest {
			// make even bolder, somehow! (or change color, or blink or something)
		}
		
		userDateLabel.text = "\(nameString ?? "") - \(timeString ?? ""))"
		songTitleLabel.text = songString
		artistLabel.text = artistString
		notesLabel.text = request.notes
		tipLabel.text = request.tip != nil ? "$\(request.tip!)" : "$0"
	}
}
