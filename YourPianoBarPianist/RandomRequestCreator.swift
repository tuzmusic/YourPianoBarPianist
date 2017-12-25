//
//  RandomRequestCreator.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 12/24/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

extension Request {
	class func randomRequest(in realm: Realm) -> Request {
		let request = Request()
		
		let userNum = arc4random_uniform(UInt32(realm.objects(YpbUser.self).count))
		request.user = realm.objects(YpbUser.self)[Int(userNum)]
		
		let songNum = arc4random_uniform(UInt32(realm.objects(Song.self).count))
		request.songObject = realm.objects(Song.self)[Int(songNum)]
		
		request.notes = "\(request.userString) wants to hear \(request.songString)"
		
		return request
	}
	
	class func createUsers(in realm: Realm) {
		let names = [ "Holly Shulman", "Brad Emmett", "Eser Ozdeger", "Erica Sackin", "David Tuzman", "Jake Adler", "Hunter Lang", "Dave Stroup", "Gail Tuzman", "Brian Lysholm", "Catie Glogovsky", "Rolando Sanz", "Moraima Ortiz", "Maggie Boland", "Rebecca Campana", "Liz Chmura", "Kerry McGee", "Laura Palmer", "Dale Cooper", "Gordon Cole", "Albert Rosenfield", "Tammy Preston", "James Hurley"]
		
		for name in names {
			let firstName = name.components(separatedBy: .whitespaces)[0]
			let lastName = name.components(separatedBy: .whitespaces)[1]
			let dummyEmail = firstName+"@"+lastName+".com"
			let _ = YpbUser.user(firstName: firstName, lastName: lastName, email: dummyEmail, in: realm) // this creator function writes the user to the realm
		}
	}
}
