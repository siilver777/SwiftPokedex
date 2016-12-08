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
     The base URL lets us construct other PokéAPI routes easily.
    */
    private static let baseURL = "http://pokeapi.co/api/v2/"
    
    /**
     The Pokémon URL without parameters can fetch a list of 20 Pokemons with names and url.
     */
    private static var pokemon: String {
        return baseURL + "pokemon/"
    }
    
    /**
     The Pokémon URL with the limit parameters can fetch more than 20 Pokémons with names and url.
     - parameter limit: The fetch limit ([1; 811]).
    */
    public static func pokemonList(limit: Int) -> String {
        return pokemon + "?limit=" + String(limit)
    }
    
    /**
     The Pokémon URL with the limit and offset parameters can fetch more than 20 Pokémons with names and url, starting with an other Pokémon than Bulbasaur.
     - parameter limit: The fetch limit ([1; 811]).
     - parameter offset: The offset to start the list ([1; 811]).
    */
    public static func pokemonList(limit: Int, offset: Int) -> String {
        return pokemonList(limit: limit) + "&offset=" + String(offset)
    }
    
    /**
     This Pokémon URL lets us fetch most details about a specific Pokémon.
     - parameter no: The ID of the Pokémon (National Pokédex numeroration).
    */
    public static func pokemon(no: Int) -> String {
        return pokemon + String(no) + "/"
    }
    
    /**
     The Pokémon Species URL without parameters can fetch a list of 20 Pokemons species with names and url.
    */
    private static var pokemonSpecies: String {
        return baseURL + "pokemon_species/"
    }
    
    /**
     This Pokémon Species URL lets us fetch details about a specific Pokémon specie.
      - parameter no: The ID of the Pokémon (National Pokédex numeroration).
     */
    public static func pokemonSpecies(no: Int) -> String {
        return pokemonSpecies + String(no) + "/"
    }
    
    /**
     The Shout Route lets us fetch the sound of a Pokémon on PokeCries.com.
      - parameter no: The ID of the Pokémon (National Pokédex numeroration).
     */
    public static func shout(no: Int) -> String {
        return "http://pokecries.com/sound/" + String(no) + ".mp3"
    }
}
