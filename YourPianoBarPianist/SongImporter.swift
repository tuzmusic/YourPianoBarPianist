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
	
	struct SongHeaderTags {
		static let title = "song"
		static let artist = "artist"
		static let genre = "genre"
	}
	
	var realm: Realm?
	
	/* queries, from realm doc 
		// Query using a predicate string
		var tanDogs = realm.objects(Dog.self).filter("color = 'tan' AND name BEGINSWITH 'B'")

		// Query using an NSPredicate
		let predicate = NSPredicate(format: "color = %@ AND name BEGINSWITH %@", "tan", "B")
		tanDogs = realm.objects(Dog.self).filter(predicate)
	
		// Sort tan dogs with names starting with "B" by name
		let sortedDogs = realm.objects(Dog.self).filter("color = 'tan' AND name BEGINSWITH 'B'").sorted(byKeyPath: "name")
	
		// Chaining queries
		let tanDogs = realm.objects(Dog.self).filter("color = 'tan'")
		let tanDogsWithBNames = tanDogs.filter("name BEGINSWITH 'B'")
	

	*/
	
	func createSong (from songComponents: [String], in realm: Realm, headers: [String]) -> Song {
		
		let newSong = Song()
		
		// TODO: Modify this to find which column is which, instead of checking that it's what I expect.
		
		if headers[0] == SongHeaderTags.title {
			newSong.title = songComponents[0]
		}
		
		if headers[1] == SongHeaderTags.artist {
			let artistName = songComponents[1]
			
			let results = realm.objects(Artist.self).filter("name = %@", artistName)
			if results.isEmpty {
				newSong.artist = Artist.newArtist(named: artistName)
			} else {
				newSong.artist = results.first
			}
		}
		
		if headers[2] == SongHeaderTags.genre {
			let genreName = songComponents[2] == "" ? "Unknown" : songComponents[2]
			let results = realm.objects(Genre.self).filter("name = %@", genreName)
			if results.isEmpty {
				newSong.genre = Genre.newGenre(named: genreName)
			} else {
				newSong.genre = results.first
			}
		}

		return newSong
	}
	
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
					for song in songList {
						let songComponents = song.components(separatedBy: "\t")
						// Check for existing song - check the local database (local realm?)
						// TODO: This should actually check the songs against the ONLINE realm.
						if let songsLocalRealm = try? Realm(fileURL: Realm.Configuration().fileURL!.deletingLastPathComponent().appendingPathComponent("songsLocal.realm"))
						{
							// Search the realm for a song with this song's title and artist.
							// This check should probably be in the createSong method. Maybe.
							if songsLocalRealm.objects(Song.self)
								.filter("title = %@ AND artist.name = %@", songComponents[0], songComponents[1])
								.isEmpty
							{
								let newSong = Song.createSong(from: songComponents, in: songsLocalRealm, headers: headers)
								try! songsLocalRealm.write {
									songsLocalRealm.add(newSong)
								}
								// Testing that the above worked
								let songsInRealm = songsLocalRealm.objects(Song.self)
								print("\(songsInRealm.count) songs added to Realm")
								for song in songsInRealm {
									songs.append(song)
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
		let localHTTP = "http://54.208.237.32:9080/~/yourPianoBarSongs/JonathanTuzman/"

		 
		SyncUser.logIn(with: .usernamePassword(username: username, password: password), server: URL(string: localHTTP)!) {
			
			// Log in the user
			user, error in
			guard let user = user else {
				print(String(describing: error!))
				return
			}
			
			DispatchQueue.main.async {
				
				// Open the online Realm
				let realmAddress = "realm://54.208.237.32:9080/~/yourPianoBarSongs/JonathanTuzman/"
				let configuration = Realm.Configuration(
					syncConfiguration: SyncConfiguration (user: user, realmURL: URL(string: realmAddress)!)
				)
				// Assign the realm to be our realm.
				// TODO: Is this the realm we want??
				do { self.realm = try Realm(configuration: configuration) } catch { print(error) }
			}
		}
	}
}

