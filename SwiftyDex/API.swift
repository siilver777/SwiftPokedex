//
//  API.swift
//  PokeStats
//
//  Created by Jason Pierna on 07/12/2016.
//  Copyright © 2016 Jason Pierna. All rights reserved.
//

import Foundation

/**
 The API class contains static properties and methods that return all the URLs needed for making necessary calls through the app.
*/
class API {
    
    /**
     The base URL lets us construct other routes easily.
    */
    private static let baseURL = "http://192.168.1.54:8080/"
    
    /**
     The Pokémon URL fetch a list of every Pokémon.
     */
    public static var pokemons: String {
        return baseURL + "pokemons/"
    }
    
    /**
     This Pokémon URL lets us fetch details about a specific Pokémon.
     - parameter no: The ID of the Pokémon (National Pokédex numeroration).
    */
    public static func pokemon(no: Int) -> String {
        return pokemons + String(no) + "/"
    }
    
    /**
     The Artwork Route lets us fetch the official artwork of a Pokémon.
     - parameter no: The ID of the Pokémon (National Pokédex numeroration).
     */
    public static func artwork(no: Int) -> String {
        return baseURL + "artworks/" + String(no) + "/"
    }
    
    /**
     The Miniature Route lets us fetch the miniature of a Pokémon.
     - parameter no: The ID of the Pokémon (National Pokédex numeroration).
     */
    public static func mini(no: Int) -> String {
        return baseURL + "minis/" + String(no) + "/"
    }
    
    /**
     The Sound Route lets us fetch the sound of a Pokémon.
      - parameter no: The ID of the Pokémon (National Pokédex numeroration).
     */
    public static func sound(no: Int) -> String {
        return baseURL + "sounds/" + String(no) + "/"
    }
}
