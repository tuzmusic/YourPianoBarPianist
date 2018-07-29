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
		let info = """
\(request.songString)
"""
	}
}
