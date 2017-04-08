//
//  ImportSongsTableViewController.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 4/8/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift

class ImportSongsTableViewController: UITableViewController {
	
	let importer = SongImporter()
	let fileName: String! = "song list 1"
	var importingSongs: [Song]!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		print(importingSongs)
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return importingSongs.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		let song = importingSongs[indexPath.row]
		cell.textLabel?.text = song.title + " - " + song.artist!.name
		cell.detailTextLabel?.text = "Genre: \(song.genre!.name)"
		
		return cell
	}
}
