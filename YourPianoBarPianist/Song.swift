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
	var requests: List<Request>?
	
	var popularity: Int { return self.requests?.count ?? 0 }
	
	
	class func createSong (from songComponents: [String], in realm: Realm, headers: [String]) -> Song {
		
		struct SongHeaderTags {
			static let title = "song"
			static let artist = "artist"
			static let genre = "genre"
		}
		
		let newSong = Song()
		
		// TODO: Modify this to find which column is which, instead of checking that it's what I expect.
		
		if headers[0] == SongHeaderTags.title {
			newSong.title = songComponents[0].capitalized
		}
		
		if headers[1] == SongHeaderTags.artist {
			let artistName = songComponents[1].capitalized
			
			let results = realm.objects(Artist.self).filter("name like[c] %@", artistName)
			if results.isEmpty {
				newSong.artist = Artist.newArtist(named: artistName)
			} else {
				newSong.artist = results.first
			}
		}
		
		if headers[2] == SongHeaderTags.genre {
			let genreName = songComponents[2] == "" ? "Unknown" : songComponents[2]
			let results = realm.objects(Genre.self).filter("name = %@", genreName)
			if results.isEmpty {
				newSong.genre = Genre.newGenre(named: genreName)
			} else {
				newSong.genre = results.first
			}
		}
		
		return newSong
	}
	
	
	// old method. just leaving it here because I can never throw anything away.
	class func newSong(named name: String, by artist: Artist, in genre: Genre, from decade: Int?) -> Song {
		let song = Song()
		song.title = name
		// check for existing artist
		song.artist = artist
		song.genre = genre
		song.decade = decade ?? nil
		return song
	}
}
