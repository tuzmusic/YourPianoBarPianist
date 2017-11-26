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
	let fileName: String! = "song list 2"
	var importingSongs: [Song]!
	
	@IBAction func uploadPressed(_ sender: Any) {
		
		let alert = UIAlertController(title: "Uploading Songs", message: "", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(alert, animated: true, completion: nil)
		alert.message = "Connecting to server..."
		var songsOnlineRealm: Realm! {
			didSet {
				alert.message! += "\n  Realm set!"
				try! songsOnlineRealm.write {
					for song in importingSongs {
						// Also give the song a primary key to allow updating (once I understand what this updating is)
						_ = Song.createSong(fromObject: song, in: songsOnlineRealm)
					}
					alert.message! += "\n  Done!"
				}
			}
		}
		func setupOnlineRealm() {
			let username = "tuzmusic@gmail.com"
			let password = "samiam"
			let localHTTP = URL(string:"http://54.208.237.32:9080")!
			
			SyncUser.logIn(with: .usernamePassword(username: username, password: password), server: localHTTP) {
				
				// Log in the user
				user, error in
				guard let user = user else {
					print(String(describing: error!)); return }
				print("Initial login successful")
				
				DispatchQueue.main.async {
					// Open the online Realm
					let realmAddress = URL(string:"realm://54.208.237.32:9080/~/YourPianoBar/JonathanTuzman/")!
					let syncConfig = SyncConfiguration (user: user, realmURL: realmAddress)
					let configuration = Realm.Configuration(syncConfiguration: syncConfig)
					
					do {
						songsOnlineRealm = try Realm(configuration: configuration)
					} catch {
						print(error)
					}
				}
			}
		}
		setupOnlineRealm()
	
	}
	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return importingSongs.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		let song = importingSongs[indexPath.row]
		cell.textLabel?.text = song.title + " - " + song.artist!.name
		//cell.detailTextLabel?.text = "Genre: \(song.genre!.name), Decade: \(song.decade.decadeNames.first)"
		
		return cell
	}
}
