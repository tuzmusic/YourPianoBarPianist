//
//  RequestDetailTableViewController.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 12/23/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

class RequestDetailTableViewController: UITableViewController {

	@IBOutlet weak var tipLabel: UILabel! { didSet { tipLabel.text = originatingCell.tipLabel.text } }
	@IBOutlet weak var nameLabel: UILabel! { didSet { nameLabel.text = originatingCell.userDateLabel.text?.components(separatedBy: " - ")[0] } }
	@IBOutlet weak var songLabel: UILabel! { didSet { songLabel.text = originatingCell.songTitleLabel.text } }
	@IBOutlet weak var timeLabel: UILabel! { didSet { timeLabel.text = originatingCell.userDateLabel.text?.components(separatedBy: " - ")[1] } }
	@IBOutlet weak var notesLabel: UILabel! { didSet { notesLabel.text = originatingCell.notesLabel.text } }
	
	var request: Request!
	var originatingCell: RequestTableViewCell!
	
}
