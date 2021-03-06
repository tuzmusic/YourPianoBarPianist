//
//  String Extensions.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/28/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
extension String {
	
	func fixXMLEscapes() -> String {
		let escapeChars = [
			"\"":"&quot;",
			"'" : "&apos;",
			"<" : "&lt;",
			">" : "&gt;",
			"&" : "&amp;"]
		
		var text: String = self
		
		for char in escapeChars.keys {
			text = text.replacingOccurrences(of: char, with: escapeChars[char]!)
		}
		
		return text
	}
	
	func forSorting() -> String {
		var startingName = self
		var editedName = startingName
		
		repeat {
			startingName = editedName
			if editedName.hasPrefix("(") && editedName.contains(")") {
				// Delete the parenthetical
				editedName = String(editedName[editedName.index(after: editedName.index(of: ")")!)..<editedName.endIndex])
			} else if !CharacterSet.alphanumerics.contains(editedName.unicodeScalars.first!) {
				// Delete any punctuation, spaces, etc.
				editedName.remove(at: editedName.index(of: editedName.first!)!)
			} else if editedName.hasPrefix("The "), let range = editedName.range(of: "The ") {
				// Delete "The"
				editedName = editedName.replacingOccurrences(of: "The ", with: "", options: [], range: range)
			}
		} while editedName != startingName
		
		return editedName
	}
	
	func capitalizedWithOddities() -> String {
		
		// Still doesn't deal with stuff like "McFerrin." Should probably just capitalize the source data correctly!
		if self.uppercased() == self { return self }
		
		var fullString = ""
		let words = self.components(separatedBy: " ")
		for word in words {
			if words.index(of: word)! > 0 {
				fullString += " " // Add a space if it's not the first word.
			}
			
			if let firstChar = word.unicodeScalars.first {
				// If it starts with a number, don't capitalize it.
				if CharacterSet.decimalDigits.contains(firstChar) {
					fullString += word
				} else if word == word.uppercased() {
					fullString += word
				} else {
					fullString += word.capitalized
				}
			}
		}
		
		if fullString.hasSuffix("S") {
			fullString = String(fullString.dropLast()) + "s"
		}
		
		return fullString
	}
}
