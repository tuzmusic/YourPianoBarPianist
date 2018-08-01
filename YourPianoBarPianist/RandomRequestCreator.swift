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
		
		request.notes = "Notes for Sample Request"
		
		return request
	}
}
