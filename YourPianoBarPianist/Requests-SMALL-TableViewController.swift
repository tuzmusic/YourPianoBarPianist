//
//  Requests-SMALL-TableViewController.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 7/29/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import UIKit

class Requests_SMALL_TableViewController: RequestsTableViewController {
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
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
}
