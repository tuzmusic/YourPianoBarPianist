//
//  Request-SMALL-Cell.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 7/29/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import UIKit

class Request_SMALL_Cell: RequestTableViewCell {
	
	@IBOutlet weak var label: UILabel!
	
	override func updateUI() {
		
		let attrString = NSMutableAttributedString()
		let titleSize: CGFloat = 20
		let subtitleSize: CGFloat = 16
		
		let boldTitleAttribute = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: titleSize)]
		let regularTitleAttribute = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: titleSize)]
		let regularSubtitleAttribute = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: subtitleSize)]
		let italicSubtitleAttribute = [NSAttributedStringKey.font : UIFont.italicSystemFont(ofSize: subtitleSize)]
		
		attrString.append(NSAttributedString(string: "\(songString ?? "")", attributes: boldTitleAttribute))

		if let artistString = artistString {
			attrString.append(NSAttributedString(string: " by \(artistString)", attributes: regularTitleAttribute))
		}
		
		if let nameString = nameString {
			attrString.append(NSAttributedString(string: "\nrequested by \(nameString)", attributes: regularSubtitleAttribute))
		}
		attrString.append(NSAttributedString(string: " \n\(timeString ?? "")", attributes: regularSubtitleAttribute))

		if !request.notes.isEmpty {
			attrString.append(NSAttributedString(string: "\n\(request.notes)", attributes: italicSubtitleAttribute))
		}
		
		label.attributedText = attrString
	}
}

