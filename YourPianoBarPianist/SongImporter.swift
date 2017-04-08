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
	
	typealias SongData = [String]
	
	func getSongDataFromTSVFile (named fileName: String) -> [SongData]? {
		
		var songData = [[String]]()
		
		if let path = Bundle.main.path(forResource: fileName, ofType: "tsv") {
			if let fullList = try? String(contentsOf: URL(fileURLWithPath: path)) {
				let songList = fullList
					.replacingOccurrences(of: "\r", with: "")
					.components(separatedBy: "\n")
				guard songList.count > 1 else { print("Song list cannot be used: no headers, or no listings!")
					return nil }
				for song in songList {
					songData.append(song.components(separatedBy: "\t"))
				}
			}
		}
		return songData
	}
	
	func writeSongsToLocalRealm(songData: [SongData]) {
		
		// Get the headers from the first entry in the database
		guard let headers = songData.first else {
			print("Song list is empty, could not extract headers.")
			return
		}
		
		let configURL = Realm.Configuration().fileURL!.deletingLastPathComponent().appendingPathComponent("songsLocal.realm")
		if let songsLocalRealm = try? Realm(fileURL: configURL) {
			for songComponents in songData where songComponents != headers {
				_ = Song.createSong(from: songComponents, in: songsLocalRealm, headers: headers)
			}
		}
	}
	
	func setupOnlineRealm() {
		
		var songsOnlineRealm: Realm?
		
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
				let realmAddress = URL(string:"realm://54.208.237.32:9080/~/yourPianoBarSongs/JonathanTuzman/")!
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
}

