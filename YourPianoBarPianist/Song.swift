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
	dynamic var artist: Artist?
	dynamic var genre: Genre?
	dynamic var year = Int()
	var decade: Int?  // Can't be dynamic. Fix?
	dynamic var decadeString: String {
		return year == 0 ? "??" : "'" + String(((year - (year<2000 ? 1900 : 2000)) / 10)) + "0s"
	}

	var requests: List<Request>?
	dynamic var dateAdded: Date?
	dynamic var dateModified: Date?
	dynamic var songDescription = ""
	
//	override static func primaryKey() -> String? {
//		return "songDescription"
//	}
	
	var popularity: Int { return self.requests?.count ?? 0 }
	
	class func createSong (from song: Song, in realm: Realm) -> Song? {

		if let existingSong = realm.objects(Song.self)
			// Should this be filtering for primary key instead? Or is there a way that Realm uniques with the primay key automatically?
			.filter("title like[c] %@ AND artist.name like[c] %@", song.title, song.artist!.name)
			.first {
			return existingSong
		}
		
		let newSong = Song()
		newSong.title = song.title
		if let artistName = song.artist?.name {
			let results = realm.objects(Artist.self).filter("name like[c] %@", artistName)
			newSong.artist = results.isEmpty ? Artist.newArtist(named: artistName) : results.first
			newSong.songDescription = "\(song.title) - \(artistName)"
		}
		
		if let genreName = song.genre?.name {
			let results = realm.objects(Genre.self).filter("name =[c] %@", genreName)
			newSong.genre = results.isEmpty ? Genre.newGenre(named: genreName) : results.first
		}
		
		newSong.decade = song.decade
		newSong.dateModified = song.dateModified
		newSong.dateAdded = song.dateAdded
		
		realm.create(Song.self, value: newSong, update: false)
		
		return newSong
	}
	
	struct SongHeaderTags {
		static let titleOptions = ["song", "title", "name"]
		static let artist = "artist"
		static let genre = "genre"
	}
	
	class func createSongUsingKeyValueCoding (from songComponents: [String], in realm: Realm, headers: inout [String]) -> Song? {
		
		var titleNum: Int? {
			for header in headers {
				if SongHeaderTags.titleOptions.contains(header) {
					return headers.index(of: header)!
				}
			}
			return nil
		}
		
		guard let titleIndex = titleNum else {
			print("Song could not be created: Title field could not be found.")
			return nil
		}
		
		// This is just for checking to see if we already have the song. This artistName won't be used in checking/assigning the artist.
		let title = songComponents[titleIndex].capitalized
		var artistName = ""
		if let artistIndex = headers.index(of: SongHeaderTags.artist) {
			artistName = songComponents[artistIndex]
		}
		
		// Check to see if we already have this song (by this artist)
		if let existingSong = realm.objects(Song.self)
			.filter("title like[c] %@ AND artist.name like[c] %@", songComponents[titleIndex], artistName)
			.first { return existingSong }
		
		let newSong = Song(value: title)
		//newSong.title = songComponents[titleIndex].capitalized
		
		for property in Song.indexedProperties() {
			if let index = headers.index(of: property.description) {
				newSong.setValue(headers[index], forKey: property.description)
			}
		}
		
		return newSong
	}
	
	class func createSong (from songComponents: [String], in realm: Realm, headers: inout [String]) -> Song? {
		
//		var titleNum: Int? {
//			for header in headers {
//				if SongHeaderTags.titleOptions.contains(header) {
//					return headers.index(of: header)!
//				}
//			}
//			return nil
//		}
		
		// Find the title
		guard let titleHeader = headers.first(where: { SongHeaderTags.titleOptions.contains($0) }),
			let titleIndex = headers.index(of: titleHeader) else
		{
			print("Song could not be created: Title field could not be found.")
			return nil
		}
		
		let title = songComponents[titleIndex].capitalized
		
		// Find the artist's name
		var artistName: String = "Unknown Artist"
		if let artistIndex = headers.index(of: SongHeaderTags.artist), !songComponents[artistIndex].isEmpty {
			artistName = songComponents[artistIndex].capitalized
		}
		
		// Check to see if we already have this song by this artist
		if let existingSong = realm.objects(Song.self).filter("title like[c] %@ AND artist.name like[c] %@", title, artistName).first {
			return existingSong
		}
		
		let newSong = Song(value: [title])
		
		/* func genericStuffThatDidntWork() {
		
		// Generic function for finding or creating objects for properties
		func objectFor<T: Object> (songProperty: String, type: T.Type, nameForBlankItem: String, createWith newObjectNamed: (String) -> T) -> T? {
			var object = T()
			var name = ""
			if let index = headers.index(of: songProperty) {
				name = songComponents[index].isEmpty ? nameForBlankItem : songComponents[index].capitalized
			} else {
				print("Could not find column for \"\(songProperty)\". Using \"\(nameForBlankItem)\".")
				name = nameForBlankItem
			}
			
			let results = realm.objects(T.self).filter("name like[c] %@", name)
			object = results.isEmpty ? newObjectNamed(name) : results.first!
			return object
		}
		
		//newSong.artist = objectFor(songProperty: SongHeaderTags.artist, type: Artist.self, nameForBlankItem: "Unknown Artist", createWith: Artist.newArtist(named:))
		
		//newSong.genre = objectFor(songProperty: SongHeaderTags.genre, type: Genre.self, nameForBlankItem: "Unknown", createWith: Genre.newGenre(named:))
		} */
		
		// If we already an  artist with this name, assign that artist to this song.
		// Otherwise create a new artist and assign it to this song.
		let artistSearch = realm.objects(Artist.self).filter("name like[c] %@", artistName)
		newSong.artist = artistSearch.isEmpty ? Artist(value: [artistName]) : artistSearch.first
		
		// Find the genre name
		var genreName: String = "Unknown"
		if let genreIndex = headers.index(of: SongHeaderTags.genre), !songComponents[genreIndex].isEmpty {
			genreName = songComponents[genreIndex].capitalized
		}
		
		// If we already a genre with this name, assign that genre to this song.
		// Otherwise create a new genre and assign it to this song.
		let genreSearch = realm.objects(Genre.self).filter("name =[c] %@", genreName)
		newSong.genre = genreSearch.isEmpty ? Genre(value: [genreName]) : genreSearch.first

		var propertiesWithoutHeaders = [String]()
		let propertiesToSkip = ["title", "artist", "genre"]

		// Iterating through properties using mirror
		/*
		let propertiesToSkip = ["title", "artist", "genre"]
		let mirror = Mirror(reflecting: newSong)

		for property in mirror.children where !propertiesToSkip.contains(property.label!) {
			if let index = headers.index(of: property.label!) {
				newSong.setValue(headers[index], forKey: property.label!)
			} else {
				propertiesWithoutHeaders.append(property.label!)
			}
		}
		*/
		
		for property in newSong.objectSchema.properties
			where !propertiesToSkip.contains(property.name)
			//where property.type != Object && property.type != List
		{
			if let index = headers.index(of: property.name) {
				newSong.setValue(songComponents[index], forKey: property.name)
			} else {
				propertiesWithoutHeaders.append(property.name)
			}
		}
		//print("Properties not in table: \n \(propertiesWithoutHeaders)")
		
		newSong.dateAdded = Date()
		try! realm.write {
			realm.add(newSong)
			let count = realm.objects(Song.self).count
			print("Song #\(count) added to realm: \(newSong)")
		}
		return newSong
	}
}
