//
//  ImportSongsViewController.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 3/28/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

class ImportSongsViewController: UIViewController {

	let importer = SongImporter()
	let fileName: String! = "song list 1"
	
	var songs = [Song]()
	
	@IBOutlet weak var fileNameLabel: UILabel! {
		didSet {
			fileNameLabel.text = fileName
		}
	}
	
	@IBAction func `import`(_ sender: Any) {
		if let songData = importer.getSongDataFromTSVFile(named: fileName) {
			importer.writeSongsToLocalRealm(songData: songData)
		}
	}
}
