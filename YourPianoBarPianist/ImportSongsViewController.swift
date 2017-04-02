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
		let songsInRealm = importer.getSongsFromFile(named: fileName)
		print(songsInRealm)
		//print(importer.realm!.objects(Song.self))
	}
}
