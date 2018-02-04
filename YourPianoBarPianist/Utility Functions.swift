//
//  Utility Functions.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/27/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift
import RealmSearchViewController

extension YPB {
	
	class func deleteDuplicateSongs (in realm: Realm) {
		var alreadyWriting = realm.isInWriteTransaction
		if alreadyWriting {
			try! realm.commitWrite()
			alreadyWriting = false
		}
		
//		if !alreadyWriting {
//			realm.beginWrite()
//		}
		
		var songsWithNoArtist = [Song]()
		let allSongs = realm.objects(Song.self)
 		for song in allSongs {
			if song.artist != nil {
				let songsWithThisTitleAndThisArtist = allSongs.filter("title = %@", song.title).filter("artist.name = %@", song.artist.name)
				//print("\(songsWithThisTitleAndThisArtist.count) songs called \(song.title) by \(song.artist.name)")
				while songsWithThisTitleAndThisArtist.count > 1 {
					let song = songsWithThisTitleAndThisArtist.last!
					let string = "Deleting, \(song.title), leaving \(songsWithThisTitleAndThisArtist.count-1) songs called \(song.title) by \(song.artist.name)"
					try! realm.write {
						realm.delete(song)
					}
					print(string)
				}
			} else {
				songsWithNoArtist.append(song)
				print("\(songsWithNoArtist.count) songs with no artist found")
			}
		}
		
//		if !alreadyWriting {
//			try! realm.commitWrite()
//		}
	
//		for song in songsWithNoArtist {
//			print("\(song.title) has no artist!")
//		}
		print("Done deleting duplicate songs")
	}
	
	class func populateNilArtists (in realm: Realm) {
		
		let alreadyWriting = realm.isInWriteTransaction
		if !alreadyWriting { realm.beginWrite() }
		
		if let nilArtist = realm.objects(Artist.self).filter("name = %@", "nil artist").first {
			for song in realm.objects(Song.self) where song.artist == nil {
				print("\(song.title) has no artist")
				song.artist = nilArtist
			}
		}
		
		if !alreadyWriting { try! realm.commitWrite() }

	}
	
	class func deleteDuplicateCategories (in realm: Realm) {
		
		let alreadyWriting = realm.isInWriteTransaction
		if !alreadyWriting {
			realm.beginWrite()
		}
		
		let allArtists = realm.objects(Artist.self)
		for artist in allArtists {
			let search = allArtists.filter("name = %@", artist.name)
			if search.count > 1 {
				if artist.songs.isEmpty {
					//print("Deleting duplicate with no songs: \(artist.name)")
					realm.delete(artist)
				}
			}
		}
		
		let allGenres = realm.objects(Genre.self)
		for genre in allGenres {
			let search = allGenres.filter("name = %@", genre.name)
			if search.count > 1 {
				if genre.songs.isEmpty {
					//print("Deleting duplicate with no songs: \(genre.name)")
					realm.delete(genre)
				}
			}
		}
		
		let allDecades = realm.objects(Decade.self)
		for decade in allDecades {
			let search = allDecades.filter("name = %@", decade.name)
			if search.count > 1 {
				if decade.songs.isEmpty {
					//print("Deleting duplicate with no songs: \(decade.name)")
					realm.delete(decade)
				}
			}
		}
		if !alreadyWriting {
			do { try realm.commitWrite() }
			catch { print("Could not delete duplicates.")}
		}
		
		print("Done deleting duplicate categories")
		
		// Attempt to genericize this that I can't get to work.
		func deleteDuplicates<T: BrowserCategory>(of type: T, in realm: Realm) {
			let allItems = realm.objects(T.self)
			for item in allItems {
				let search = allItems.filter("name = %@", item.name)
				if search.count > 1 {
					print("Found duplicate: \(item.name)")
					//if item.songs.isEmpty {		this is the line that doesn't work
					print("Deleting duplicate with no songs: \(item.name)")
					try! realm.write {
						realm.delete(item)
					}
					//}
				}
			}
		}
	}
	
	class func createBloggerBlogFromSongCatalog() {
		
	}
	
	class func writeSongCatalogToTxtFile () {
		
		/*
		func precedeSecondArtistWithComma() {
		for song in YPB.realmLocal.objects(Song.self) {
		var components = song.songDescription.components(separatedBy: " - ")
		if components.count > 2 {
		var newDescription = components[0] + " - " + components[1]
		for i in 2 ..< components.count {
		newDescription += ", " + components[i]
		}
		try! YPB.realmLocal.write {
		song.songDescription = newDescription
		}
		}
		}
		} */
		
		// Assemble the text
		var text = ""
		
		let decades = YPB.realmLocal.objects(Decade.self)
		
		for decade in decades {
			var songsArray = [Song]()
			for song in decade.songs {
				songsArray.append(song)
			}
			songsArray.sort { $0.songDescription < $1.songDescription }
			text += "\n" + decade.name + "\n"
			for song in songsArray {
				text += song.songDescription + " / "
			}
		}
		
		let fileName = "songCatalog.txt" //this is the file. we will write to and read from it
		if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			let path = dir.appendingPathComponent(fileName)
			do {
				try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
			}
			catch {
				print("Couldn't write file")
			}
		}
	}
}



