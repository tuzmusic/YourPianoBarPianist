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
		guard var headers = songData.first?.map({$0.lowercased()}) else {
			print("Song list is empty, could not extract headers.")
			return
		}
		
		let configURL = Realm.Configuration().fileURL!.deletingLastPathComponent().appendingPathComponent("songsLocal.realm")
		do {
			let songsLocalRealm = try Realm(fileURL: configURL)
			for songComponents in songData where songComponents.map({$0.lowercased()}) != headers {
				var shouldImport = true
				if let appIndex = headers.index(of: "app") {
					if songComponents[appIndex] != "Y" { shouldImport = false }
				}
				if shouldImport {
					_ = Song.createSong(from: songComponents, in: songsLocalRealm, headers: &headers)
				}
			}
		} catch {
			print(error)
		}
	}
	
	
}

