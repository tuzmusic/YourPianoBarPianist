//
//  YPB.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

class YPB {
	
	static var currentRequest: Request?
	
	static var realmSynced: Realm!
	static var realmLocal = try! Realm() {
		didSet {
			if YPB.realmLocal.objects(Song.self).isEmpty {
				SongImporter().importSongs()
			}
		}
	}
	
	static var ypbUser: YpbUser!
	
	struct UserInfo {
		var firstName = ""
		var lastName = ""
		var email = ""
	}
	
	class func setupRealm() {
		
		struct RealmConstants {
			
			static let localHTTP = URL(string:"http://54.208.237.32:9080")!
			static let publicDNS = URL(string:"http://ec2-54-208-237-32.compute-1.amazonaws.com:9080")!
			static let realmAddress = URL(string:"realm://ec2-54-208-237-32.compute-1.amazonaws.com:9080/YourPianoBar/JonathanTuzman/")!
			
			static func tokenString() -> String { return "ewoJImlkZW50aXR5IjogIl9fYXV0aCIsCgkiYWNjZXNzIjogWyJ1cGxvYWQiLCAiZG93bmxvYWQiLCAibWFuYWdlIl0KfQo=:H1qgzZHbRSYdBs0YoJON7ehUZdVDQ8wGKwgYWsQUoupYPycq1cC4PlGZlDZ++Q+gB2ouYcw4bRRri2Z3F5dlWALLWvARgEwB2bDmuOQRcH30IKkdhFp11PnE3StiMn30TDZWWzX31QAyPDvaUyES7/VK/y8CDHmJ8L/UJ/y8w422bmIFTlectnuXBzMRboBZ8JD/PSrXciaPhm9hd/jEEfgYTwB7oyuuch9XrWvPbSrcpWXEr/6j526nuoips1+KTA/h25LzAgCs1+ZeO63RFKi/K3q7y/HkRBB8OWgK9kBQZGIx8eiH4zu7ut4mLGBcs38JnJr4OEvSTSfdZdhGxw==" }
			
			static let userCred = SyncCredentials.usernamePassword(username: "tuzmusic@gmail.com", password: "samiam")
			static let tokenCred = SyncCredentials.accessToken(RealmConstants.tokenString(), identity: "admin")
			//static let tokenCred = SyncCredentials.accessToken("wrong string", identity: "admin")
			
			// Paste into terminal to SSH into EC2:
			/*
			ssh -i /Users/TuzsNewMacBook/Library/Mobile\ Documents/com\~apple\~CloudDocs/Misc\ Stuff\ -\ iCloud\ drive/Programming/IMPORTANT\ Server\ Stuff/KeyPairs/YourPianoBarKeyPair.pem ubuntu@ec2-54-208-237-32.compute-1.amazonaws.com
			*/
			
		}
		
		SyncUser.logIn(with: RealmConstants.userCred, server: RealmConstants.publicDNS) {
			
			// Log in the user. If not, use local Realm config. If unable, return nil.
			user, error in
			guard let user = user else {
				print("Could not access server. Using local Realm [default configuration].")
				if YPB.realmLocal.objects(Song.self).isEmpty {
					SongImporter().importSongs()
				}
				return
			}
			
			DispatchQueue.main.async {
				
				// Open the online Realm
				let syncConfig = SyncConfiguration (user: user, realmURL: RealmConstants.realmAddress)
				let configuration = Realm.Configuration(syncConfiguration: syncConfig)
				
				YPB.realmSynced = try! Realm(configuration: configuration)
				
				/*
				try! YPB.realmSynced.write {
				YPB.realmSynced.deleteAll()
				}
				try! YPB.realmLocal.write {
				YPB.realmLocal.deleteAll()
				}
				*/
				if YPB.realmLocal.objects(Song.self).isEmpty {
					if YPB.realmSynced.objects(Song.self).isEmpty {
						// this isn't quite right... or at least it should be named something else
						YPB.populateSyncedRealmFromLocalRealm()
					}
					YPB.populateLocalRealmFromSyncedRealm()
				}
				YPB.deleteDuplicateCategories(in: YPB.realmLocal)
			}
		}
	}

	class func populateLocalRealmFromSyncedRealm() {
		let onlineSongs = YPB.realmSynced.objects(Song.self)
		for song in onlineSongs {
			try! YPB.realmLocal.write {
				_ = Song.createSong(fromObject: song, in: YPB.realmLocal)
			}
		}
	}
	
	class func emptyLocalRealm() {
		try! YPB.realmLocal.write { YPB.realmLocal.deleteAll() }
	}
	
	class func populateSyncedRealmFromLocalRealm() {
		let offlineSongs = YPB.realmLocal.objects(Song.self)
		if offlineSongs.isEmpty {
			SongImporter().importSongs()
		}
		
		for song in offlineSongs {
			try! YPB.realmSynced.write {
				_ = Song.createSong(fromObject: song, in: YPB.realmSynced)
			}
		}
	}
	
}


