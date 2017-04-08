//
//  Song.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 3/24/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

final class Song: Object {
	dynamic var title = ""
	var artist: Artist?
	var genre: Genre?
	var decade: Int?
	dynamic var decadeString = ""
	var requests: List<Request>?
	var dateAdded: Date?
	var dateModified: Date?
	
	var popularity: Int { return self.requests?.count ?? 0 }
	
	class func createSong (from songComponents: [String], in realm: Realm, headers: inout [String]) -> Song? {
		
		headers.forEach { $0 = $0.lowercased() }
		
		// Prep the data
		struct SongHeaderTags {
			static let titleOptions = ["song", "title", "name"]
			static let artist = "artist"
			static let genre = "genre"
			static let decade = "decade"
			static let dateModified = "date modified"
		}
		
		var titleNum: Int? {
			for option in SongHeaderTags.titleOptions {
				for header in headers {
					if header == option {
						return headers.index(of: header)!
					}
				}
			}
			return nil
		}
		
		guard let titleIndex = titleNum else {
			print("Song could not be created: Title field could not be found.")
			return nil
		}
		
		// This is just for checking to see if we already have the song. This artistName won't be used in checking/assigning the artist.
		var artistName = ""
		if let artistIndex = headers.index(of: SongHeaderTags.artist) {
			artistName = songComponents[artistIndex]
		}
		
		// Check to see if we already have this song (by this artist)
		if let existingSong = realm.objects(Song.self)
			.filter("title like[c] %@ AND artist.name like[c] %@", songComponents[titleIndex], artistName)
			.first {
			return existingSong
		}
		
		let newSong = Song()
		newSong.title = songComponents[titleIndex].capitalized
		
		// Generic function for finding or creating objects for properties
		func objectFor<T: Object> (songProperty: String, type: T.Type, nameForBlankItem: String, createWith newObjectNamed: (String) -> T) -> T? {
			var object = T()
			var name = ""
			if let index = headers.index(of: songProperty.capitalized) {
				name = songComponents[index].isEmpty ? nameForBlankItem : songComponents[index].capitalized
			} else {
				print("Could not find column for \"\(songProperty)\". Using \"\(nameForBlankItem)\".")
				name = nameForBlankItem
			}
			
			let results = realm.objects(T.self).filter("name like[c] %@", name)
			object = results.isEmpty ? newObjectNamed(name) : results.first!
			return object
		}
		
		newSong.artist = objectFor(songProperty: SongHeaderTags.artist, type: Artist.self,
		                          nameForBlankItem: "Unknown Artist", createWith: Artist.newArtist(named:))
		
		newSong.genre = objectFor(songProperty: SongHeaderTags.genre, type: Genre.self,
		                         nameForBlankItem: "Unknown", createWith: Genre.newGenre(named:))
		
		// Generic function for creating values for properties
		func valueFor (songProperty: String) -> Any? {
			if let index = headers.index(of: songProperty.capitalized) {
				return songComponents[index] as Any // does this work if the column is blank?
			} else {
				print("Could not find column for \"\(songProperty)\".")
			}
			return nil
		}
		
		newSong.decade = valueFor(songProperty: SongHeaderTags.decade) as? Int
		newSong.dateModified = valueFor(songProperty: SongHeaderTags.dateModified) as? Date
		newSong.dateAdded = Date()

		/*
		if let artistIndex = headers.index(of: SongHeaderTags.artist) {
		let artistName = songComponents[artistIndex].isEmpty ? "Unknown Artist" : songComponents[artistIndex].capitalized
		let results = realm.objects(Artist.self).filter("name like[c] %@", artistName)
		newSong.artist = results.isEmpty ? Artist.newArtist(named: artistName) : results.first
		}
		
		if let genreIndex = headers.index(of: SongHeaderTags.genre) {
		let genreName = songComponents[genreIndex].isEmpty ? "Unknown" : songComponents[genreIndex].capitalized
		let results = realm.objects(Genre.self).filter("name =[c] %@", genreName)
		newSong.genre = results.isEmpty ? Genre.newGenre(named: genreName) : results.first
		}
		*/
		
		try! realm.write { realm.add(newSong) }
		return newSong
	}
}
