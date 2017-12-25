//
//  Realm Object Classes.swift
//  Song Browser
//
//  Created by Jonathan Tuzman on 3/19/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

final class Request: Object {
	
	@objc dynamic var user: YpbUser? {
		didSet {
			if let user = user {
				userString = user.firstName + " " + user.lastName
			}
		}
	}
	
	@objc dynamic var userString: String = ""
	@objc dynamic var songString: String = ""
	@objc dynamic var songObject: Song? {
		didSet {
			if let song = songObject {
				songString = "\(song.title) by \(song.artist.name)"
			}
		}
	}
	@objc dynamic var notes: String = ""
	@objc dynamic var date = Date()
	var tip: Double? //pretty sure this isn't @objc dynamic because realm doesn't do optional doubles, at least not simply. it's probably best to make this not an optional.
	@objc dynamic var played = false
	@objc dynamic var event: Event?
	
	// Implement later
	@objc dynamic var singAtMic = false
	
	class func addSampleRequest() -> Bool {
		if let realm = YPB.realmSynced {
			let user = YpbUser.user(firstName: "Jonathan", lastName: "Tuzman", email: "tuzmusic@gmail.com", in: realm)
			let request = Request()
			let requestsInRealm = realm.objects(Request.self).count
			request.user = user
			request.songObject = realm.objects(Song.self)[requestsInRealm]
			request.songString = request.songObject!.title
			request.notes = "Sample request #\(requestsInRealm)"
			try! realm.write {
				realm.create(Request.self, value: request, update: false)
			}
			return true
		} else {
			return false
		}
	}	
}


