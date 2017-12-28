//
//  Event.swift
//  YourPianoBarPianist
//
//  Created by Jonathan Tuzman on 12/24/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

final class Event: Object {
	@objc dynamic var name: String = "General"
	@objc dynamic var date: Date?
	var type: EventType?
	
	enum EventType {
		case pianoBar
		case weddingNoTip
		case openMic
	}
}
