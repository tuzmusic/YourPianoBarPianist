//
//  Globals, Extensions, Etc.swift
//  Song Importer
//
//  Created by Jonathan Tuzman on 3/17/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation

struct Storyboard {
	static let CategorySegue = "Category Segue"
	static let SongSegue = "Songs Segue"
	static let ArtistsSongsSegue = "Artist's Songs Segue"
	static let GenresArtistsSegue = "Genre's Artists Segue"
	static let BrowseSongsSegue = "Browse Songs Segue"
	static let SelectSongSegue = "Select Song Segue"
	static let ImportSongsSegue = "Import Songs Segue"
	static let ImportSongsTable = "Import Songs Table"
}

struct Info {
	static let Artist = "artist"
	static let Song = "song"
	static let Genre = "genre"
}

extension String {
	// I don't actually need this anymore, I needed it for populating what used to be the root of the table.
	var pluralCap: String {
		get {
			return self.lowercased() + "s"
		}
	}
}

// This isn't working, but, one day, maybe, whatever.
protocol CategoryBrowser {
	func viewDidLoad()
}

/* NOTES

Sometimes switching back to SONGS turns black!

Search songs, switch to artist, switch back to songs -- black! (search inside songs persists)
Clearing search, switching out and back, fixes it

*/
