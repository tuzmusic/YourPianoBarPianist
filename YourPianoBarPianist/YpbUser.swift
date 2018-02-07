//
//  YpbUser.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/25/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

final class YpbUser: Object {
	
	public static var current: YpbUser?
	
	@objc dynamic var id: String = "" // copied from realm SyncUser
	@objc dynamic var email: String = ""
	@objc dynamic var firstName: String = ""
	@objc dynamic var lastName: String = ""
	@objc dynamic var registeredDate = Date()

	let requests = LinkingObjects(fromType: Request.self, property: "user")
	
	var tips: [Double] {
		var tips = [Double]()
		for request in requests where request.tip != nil {
			tips.append(request.tip!)
		}
		return tips
	}
	
	var averageTip: Double {
		return tips.reduce(0, { $0 + $1 }) / Double(tips.count)
	}
	
	class func user(id: String?, email: String, firstName: String, lastName: String?) -> YpbUser {
		let user = YpbUser()
		user.id = id ?? ""
		user.email = email
		user.firstName = firstName
		user.lastName = lastName ?? ""
		
		return user
	}
	
	class func user(firstName: String, lastName: String, email: String, in realm: Realm) -> YpbUser? {
		if let existingUser = realm.objects(YpbUser.self).filter("email =[c] %@", email).first
		{
			return existingUser
		} else {
			let user = YpbUser()
			user.firstName = firstName
			user.lastName = lastName
			user.email = email
			try! realm.write {
				realm.add(user)
			}
			return user
		}
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
