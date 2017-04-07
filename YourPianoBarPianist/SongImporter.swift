//
//  Importer.swift
//  Song Importer
//
//  Created by Jonathan Tuzman on 3/16/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

class SongImporter {
	
	var songsOnlineRealm: Realm?
	
	func getSongsFromFile (named fileName: String) -> [Song] {
		
		var songs = Array<Song>()
		
		if let path = Bundle.main.path(forResource: fileName, ofType: "tsv") {
			// Get contents of TSV database file
			if let fullList = try? String(contentsOf: URL(fileURLWithPath: path)).replacingOccurrences(of: "\r", with: "") {
				// Separate each record in the database and store them in songList
				var songList = fullList.components(separatedBy: "\n")
				if !songList.isEmpty {
					// Get the headers from the first entry in the database
					let headers = songList.removeFirst().components(separatedBy: "\t")
					setupRealm()
					for song in songList {
						let songComponents = song.components(separatedBy: "\t")
						// TODO: This should actually check the songs against the ONLINE realm.
						if let songsLocalRealm = try? Realm(fileURL: Realm.Configuration().fileURL!.deletingLastPathComponent().appendingPathComponent("songsLocal.realm"))
						{
							// This check should probably be in the createSong method. Maybe.
							if songsLocalRealm.objects(Song.self)
								.filter("title = %@ AND artist.name = %@", songComponents[0], songComponents[1])
								.isEmpty
							{
								let newSong = Song.createSong(from: songComponents, in: songsLocalRealm, headers: headers)
								songs.append(newSong)
								try! songsLocalRealm.write { songsLocalRealm.add(newSong) }
								do {
									try songsOnlineRealm?.write {
										songsOnlineRealm?.add(newSong)
										print("Song added to online realm")
									}
								} catch {
									print("Error when trying to write song to online realm:\(error)")
								}
							}
						}
					}
				}
			}
		}
		return songs
	}
	
	func setupRealm() {
		
		let username = "tuzmusic@gmail.com"
		let password = "samiam"
		let localHTTP = URL(string:"http://54.208.237.32:9080")!
		
		
		SyncUser.logIn(with: .usernamePassword(username: username, password: password), server: localHTTP) {
			
			// Log in the user
			user, error in
			guard let user = user else {
				print(String(describing: error!))
				return
			}
			print("Initial login successful")
			DispatchQueue.main.async {
				
				// Open the online Realm
				let realmAddress = "realm://54.208.237.32:9080/~/yourPianoBarSongs/JonathanTuzman/"
				let configuration = Realm.Configuration(
					syncConfiguration: SyncConfiguration (user: user, realmURL: URL(string: realmAddress)!)
				)
				// Assign the realm to be our realm.
				// TODO: Is this the realm we want??
				do {
					self.songsOnlineRealm = try Realm(configuration: configuration)
				} catch {
					print(error)
				}
			}
		}
	}
}

