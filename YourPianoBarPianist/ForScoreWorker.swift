//
//  File.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 3/15/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import Foundation

extension RequestsTableViewController {
	
	func forScorePath(for string: String) -> URL? {
		let path = string.replacingOccurrences(of: " ", with: "%20")
		let finalPath = "forscore://open?score=\(path)"
		return URL(string: finalPath)
	}
	
}
